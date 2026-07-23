/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_SPEF_HOME_LXQ_AIEDA_IEDA_AI_BUILD_AES13_SRC_OPERATION_IRCX_SPEF_PARSER_GENERATED_SPEF_PARSER_HPP_INCLUDED
# define YY_SPEF_HOME_LXQ_AIEDA_IEDA_AI_BUILD_AES13_SRC_OPERATION_IRCX_SPEF_PARSER_GENERATED_SPEF_PARSER_HPP_INCLUDED
/* Debug traces.  */
#ifndef SPEF_DEBUG
# if defined YYDEBUG
#if YYDEBUG
#   define SPEF_DEBUG 1
#  else
#   define SPEF_DEBUG 0
#  endif
# else /* ! defined YYDEBUG */
#  define SPEF_DEBUG 0
# endif /* ! defined YYDEBUG */
#endif  /* ! defined SPEF_DEBUG */
#if SPEF_DEBUG
extern int spef_debug;
#endif
/* "%code requires" blocks.  */
#line 1 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"

#include <cstdlib>

#include "SpefParser.hh"

#line 63 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.hpp"

/* Token kinds.  */
#ifndef SPEF_TOKENTYPE
# define SPEF_TOKENTYPE
  enum spef_tokentype
  {
    SPEF_EMPTY = -2,
    SPEF_EOF = 0,                  /* "end of file"  */
    SPEF_error = 256,              /* error  */
    SPEF_UNDEF = 257,              /* "invalid token"  */
    EOL = 258,                     /* EOL  */
    K_NAME_MAP = 259,              /* K_NAME_MAP  */
    K_PORTS = 260,                 /* K_PORTS  */
    K_CONN = 261,                  /* K_CONN  */
    K_CAP = 262,                   /* K_CAP  */
    K_RES = 263,                   /* K_RES  */
    K_END = 264,                   /* K_END  */
    K_D_NET = 265,                 /* K_D_NET  */
    K_COORD = 266,                 /* K_COORD  */
    K_LOAD = 267,                  /* K_LOAD  */
    K_DRIVE = 268,                 /* K_DRIVE  */
    K_LL = 269,                    /* K_LL  */
    K_UR = 270,                    /* K_UR  */
    K_LAYER = 271,                 /* K_LAYER  */
    K_IGNORE_ATTR = 272,           /* K_IGNORE_ATTR  */
    HEADER_KEY = 273,              /* HEADER_KEY  */
    CONN_TYPE = 274,               /* CONN_TYPE  */
    DIRECTION = 275,               /* DIRECTION  */
    NAME_REF = 276,                /* NAME_REF  */
    SPEF_NAME = 277,               /* SPEF_NAME  */
    QUOTED_STRING = 278,           /* QUOTED_STRING  */
    NUMBER = 279                   /* NUMBER  */
  };
  typedef enum spef_tokentype spef_token_kind_t;
#endif

/* Value type.  */
#if ! defined SPEF_STYPE && ! defined SPEF_STYPE_IS_DECLARED
union SPEF_STYPE
{
#line 12 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"

  char* str;
  int ival;

#line 109 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.hpp"

};
typedef union SPEF_STYPE SPEF_STYPE;
# define SPEF_STYPE_IS_TRIVIAL 1
# define SPEF_STYPE_IS_DECLARED 1
#endif


extern SPEF_STYPE spef_lval;


int spef_parse (spef::ParserContext* context);

/* "%code provides" blocks.  */
#line 7 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"

int spef_lex(void);
void spef_error(spef::ParserContext* context, const char* message);

#line 129 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.hpp"

#endif /* !YY_SPEF_HOME_LXQ_AIEDA_IEDA_AI_BUILD_AES13_SRC_OPERATION_IRCX_SPEF_PARSER_GENERATED_SPEF_PARSER_HPP_INCLUDED  */
