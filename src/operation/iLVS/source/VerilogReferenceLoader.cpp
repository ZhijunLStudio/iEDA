// ***************************************************************************************
// Copyright (c) 2026-2030 Southeast University
// Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************

#include "VerilogReferenceLoader.hpp"

#include <algorithm>
#include <cctype>
#include <fstream>
#include <map>
#include <set>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

namespace ilvs {
namespace {

enum class TokenKind
{
  kIdentifier,
  kNumber,
  kSymbol,
  kEnd
};

struct Token
{
  TokenKind kind = TokenKind::kEnd;
  std::string text;
};

auto isIdentStart(char ch) -> bool
{
  return std::isalpha(static_cast<unsigned char>(ch)) != 0 || ch == '_' || ch == '$' || ch == '\\';
}

auto isIdentBody(char ch) -> bool
{
  return std::isalnum(static_cast<unsigned char>(ch)) != 0 || ch == '_' || ch == '$' || ch == '\\' || ch == '[' || ch == ']' || ch == ':';
}

auto stripComments(const std::string& text) -> std::string
{
  std::string result;
  result.reserve(text.size());
  for (std::size_t index = 0; index < text.size();) {
    if (index + 1 < text.size() && text[index] == '/' && text[index + 1] == '/') {
      index += 2;
      while (index < text.size() && text[index] != '\n') {
        ++index;
      }
      continue;
    }
    if (index + 1 < text.size() && text[index] == '/' && text[index + 1] == '*') {
      index += 2;
      while (index + 1 < text.size() && !(text[index] == '*' && text[index + 1] == '/')) {
        ++index;
      }
      index = std::min(index + 2, text.size());
      continue;
    }
    result.push_back(text[index++]);
  }
  return result;
}

auto tokenize(const std::string& text) -> std::vector<Token>
{
  const std::string clean_text = stripComments(text);
  std::vector<Token> tokens;
  for (std::size_t index = 0; index < clean_text.size();) {
    const char ch = clean_text[index];
    if (std::isspace(static_cast<unsigned char>(ch)) != 0) {
      ++index;
      continue;
    }
    if (isIdentStart(ch)) {
      std::size_t end = index + 1;
      while (end < clean_text.size() && isIdentBody(clean_text[end])) {
        ++end;
      }
      tokens.push_back({TokenKind::kIdentifier, clean_text.substr(index, end - index)});
      index = end;
      continue;
    }
    if (std::isdigit(static_cast<unsigned char>(ch)) != 0) {
      std::size_t end = index + 1;
      while (end < clean_text.size() && (std::isalnum(static_cast<unsigned char>(clean_text[end])) != 0 || clean_text[end] == '\'')) {
        ++end;
      }
      tokens.push_back({TokenKind::kNumber, clean_text.substr(index, end - index)});
      index = end;
      continue;
    }
    tokens.push_back({TokenKind::kSymbol, std::string(1, ch)});
    ++index;
  }
  tokens.push_back({TokenKind::kEnd, ""});
  return tokens;
}

struct PortConnection
{
  std::string port;
  std::string net;
};

struct InstanceDecl
{
  std::string cell_type;
  std::string name;
  std::vector<PortConnection> connections;
};

struct ModuleDecl
{
  std::string name;
  std::set<std::string> nets;
  std::vector<InstanceDecl> instances;
};

class Parser
{
 public:
  explicit Parser(std::vector<Token> tokens) : _tokens(std::move(tokens)) {}

  auto parseModules() -> std::vector<ModuleDecl>
  {
    std::vector<ModuleDecl> modules;
    while (!isEnd()) {
      if (peek("module")) {
        modules.push_back(parseModule());
      } else {
        advance();
      }
    }
    return modules;
  }

 private:
  auto isEnd() const -> bool { return _tokens.at(_cursor).kind == TokenKind::kEnd; }
  auto peek(const std::string& text) const -> bool { return _tokens.at(_cursor).text == text; }
  auto consume(const std::string& text) -> bool
  {
    if (!peek(text)) {
      return false;
    }
    ++_cursor;
    return true;
  }
  auto advance() -> Token { return _tokens.at(_cursor++); }
  auto expectIdentifier(const std::string& context) -> std::string
  {
    const Token token = advance();
    if (token.kind != TokenKind::kIdentifier) {
      throw std::runtime_error("expected identifier while parsing " + context);
    }
    return token.text;
  }
  void skipUntil(const std::string& text)
  {
    while (!isEnd() && !consume(text)) {
      advance();
    }
  }
  auto parseNetExpr() -> std::string
  {
    if (peek("{")) {
      throw std::runtime_error("Verilog concat connection is unsupported in M1 canonical loader");
    }
    const Token token = advance();
    if (token.kind == TokenKind::kNumber) {
      throw std::runtime_error("Verilog constant connection is unsupported in M1 canonical loader");
    }
    if (token.kind != TokenKind::kIdentifier) {
      throw std::runtime_error("expected net expression");
    }
    return token.text;
  }
  void parseDeclaration(ModuleDecl& module)
  {
    const std::string keyword = advance().text;
    while (!isEnd() && !consume(";")) {
      if (peek("[") || peek("]") || peek(":") || peek(",")) {
        advance();
        continue;
      }
      const Token token = advance();
      if (token.kind == TokenKind::kIdentifier) {
        module.nets.insert(token.text);
      }
    }
    if (keyword == "supply0") {
      module.nets.insert("1'b0");
    } else if (keyword == "supply1") {
      module.nets.insert("1'b1");
    }
  }
  auto parseInstance() -> InstanceDecl
  {
    InstanceDecl instance;
    instance.cell_type = expectIdentifier("cell type");
    instance.name = expectIdentifier("instance name");
    if (!consume("(")) {
      throw std::runtime_error("expected instance connection list");
    }
    while (!isEnd() && !consume(")")) {
      if (consume(",")) {
        continue;
      }
      if (!consume(".")) {
        throw std::runtime_error("only named Verilog port connections are supported");
      }
      PortConnection connection;
      connection.port = expectIdentifier("port name");
      if (!consume("(")) {
        throw std::runtime_error("expected named port open paren");
      }
      connection.net = parseNetExpr();
      if (!consume(")")) {
        throw std::runtime_error("expected named port close paren");
      }
      instance.connections.push_back(std::move(connection));
    }
    if (!consume(";")) {
      throw std::runtime_error("expected semicolon after instance");
    }
    return instance;
  }
  auto parseModule() -> ModuleDecl
  {
    consume("module");
    ModuleDecl module;
    module.name = expectIdentifier("module name");
    if (consume("(")) {
      while (!isEnd() && !consume(")")) {
        if (!consume(",")) {
          advance();
        }
      }
    }
    if (!consume(";")) {
      throw std::runtime_error("expected semicolon after module header");
    }
    while (!isEnd() && !consume("endmodule")) {
      if (peek("input") || peek("output") || peek("inout") || peek("wire") || peek("tri") || peek("supply0") || peek("supply1")) {
        parseDeclaration(module);
      } else if (peek("assign")) {
        throw std::runtime_error("Verilog assign statement is unsupported in M1 canonical loader");
      } else {
        module.instances.push_back(parseInstance());
      }
    }
    return module;
  }

  std::vector<Token> _tokens;
  std::size_t _cursor = 0;
};

auto chooseModule(const std::vector<ModuleDecl>& modules, const VerilogReferenceOptions& options) -> ModuleDecl
{
  if (modules.empty()) {
    throw std::runtime_error("Verilog contains no modules");
  }
  if (!options.top_module.empty()) {
    for (const auto& module : modules) {
      if (module.name == options.top_module) {
        return module;
      }
    }
    throw std::runtime_error("top module not found: " + options.top_module);
  }
  return modules.back();
}

}  // namespace

auto loadVerilogReferenceGraph(const std::string& verilog_text, const VerilogReferenceOptions& options) -> LvsGraph
{
  Parser parser(tokenize(verilog_text));
  const ModuleDecl module = chooseModule(parser.parseModules(), options);

  LvsGraph graph;
  graph.provenance_id = module.name.empty() ? "verilog_reference" : module.name;
  graph.coverage.checked_layers.insert("logical");

  std::set<std::string> nets = module.nets;
  for (const auto& instance : module.instances) {
    graph.vertices.push_back({"inst:" + instance.name, VertexKind::kInstance, instance.name, instance.cell_type, ""});
    graph.coverage.checked_cells.insert(instance.cell_type);
    for (const auto& connection : instance.connections) {
      nets.insert(connection.net);
    }
  }
  for (const auto& net : nets) {
    graph.vertices.push_back({"net:" + net, VertexKind::kNet, net, "", ""});
  }
  for (const auto& instance : module.instances) {
    std::set<std::string> seen_ports;
    for (const auto& connection : instance.connections) {
      if (!seen_ports.insert(connection.port).second) {
        graph.coverage.unsupported_cells.insert(instance.cell_type + ":duplicate_port:" + connection.port);
        continue;
      }
      const std::string pin_id = "pin:" + instance.name + "/" + connection.port;
      graph.vertices.push_back({pin_id, VertexKind::kPin, connection.port, "", connection.port});
      graph.edges.push_back({"inst:" + instance.name, pin_id, EdgeKind::kPinOfInstance});
      graph.edges.push_back({pin_id, "net:" + connection.net, EdgeKind::kPinOnNet});
    }
  }
  return graph;
}

auto loadVerilogReferenceGraphFile(const std::string& path, const VerilogReferenceOptions& options) -> LvsGraph
{
  std::ifstream input(path);
  if (!input.is_open()) {
    throw std::runtime_error("cannot open Verilog reference: " + path);
  }
  std::ostringstream stream;
  stream << input.rdbuf();
  return loadVerilogReferenceGraph(stream.str(), options);
}

}  // namespace ilvs
