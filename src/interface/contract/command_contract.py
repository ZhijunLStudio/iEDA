#!/usr/bin/env python3
"""Interface command contract shared by Tcl/Python migration tests."""

from __future__ import annotations

import json
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Callable, Iterable, Mapping


SCHEMA_VERSION = "ieda.interface.command_result.v1"


class CommandContractError(RuntimeError):
    """Raised when an interface command violates the shared Tcl/Python contract."""


@dataclass(frozen=True)
class CommandProduct:
    name: str
    path: Path
    schema_key: str = "schema_version"
    schema_value: str | None = None


@dataclass(frozen=True)
class CommandContract:
    name: str
    allowed_options: frozenset[str] = field(default_factory=frozenset)
    dependencies: tuple[str, ...] = ()
    products: tuple[CommandProduct, ...] = ()
    compat_mode: bool = False


@dataclass(frozen=True)
class CommandResult:
    command: str
    ok: bool
    rc: int
    reason: str
    api_success: bool
    deps_satisfied: bool
    products_valid: bool
    compat_mode: bool

    def to_dict(self) -> dict[str, Any]:
        return {
            "schema_version": SCHEMA_VERSION,
            "command": self.command,
            "ok": self.ok,
            "rc": self.rc,
            "reason": self.reason,
            "api_success": self.api_success,
            "deps_satisfied": self.deps_satisfied,
            "products_valid": self.products_valid,
            "compat_mode": self.compat_mode,
        }

    def to_json(self) -> str:
        return json.dumps(self.to_dict(), sort_keys=True)


def validate_options(contract: CommandContract, options: Mapping[str, Any]) -> None:
    unknown = sorted(set(options) - set(contract.allowed_options))
    if unknown and not contract.compat_mode:
        raise CommandContractError(f"{contract.name}: unknown option(s): {', '.join(unknown)}")


def validate_dependencies(contract: CommandContract, satisfied_dependencies: Iterable[str]) -> tuple[bool, str]:
    satisfied = set(satisfied_dependencies)
    missing = [dependency for dependency in contract.dependencies if dependency not in satisfied]
    if missing:
        return False, f"missing dependency: {', '.join(missing)}"
    return True, ""


def validate_products(products: Iterable[CommandProduct]) -> tuple[bool, str]:
    for product in products:
        if not product.path.exists():
            return False, f"missing product: {product.name}"
        if product.schema_value is not None:
            try:
                payload = json.loads(product.path.read_text())
            except json.JSONDecodeError as error:
                return False, f"invalid product schema: {product.name}: {error.msg}"
            if payload.get(product.schema_key) != product.schema_value:
                return False, f"unexpected product schema: {product.name}"
    return True, ""


def evaluate_command_result(
    contract: CommandContract,
    *,
    api_success: bool,
    options: Mapping[str, Any],
    satisfied_dependencies: Iterable[str] = (),
) -> CommandResult:
    validate_options(contract, options)
    deps_ok, deps_reason = validate_dependencies(contract, satisfied_dependencies)
    products_ok, products_reason = validate_products(contract.products)
    ok = api_success and deps_ok and products_ok
    if ok:
        reason = "ok"
    elif not api_success:
        reason = "api failed"
    elif not deps_ok:
        reason = deps_reason
    else:
        reason = products_reason
    return CommandResult(
        command=contract.name,
        ok=ok,
        rc=0 if ok else 1,
        reason=reason,
        api_success=api_success,
        deps_satisfied=deps_ok,
        products_valid=products_ok,
        compat_mode=contract.compat_mode,
    )


def tcl_rc(result: CommandResult) -> int:
    return 1 if result.ok else 0


def python_return_or_raise(result: CommandResult) -> dict[str, Any]:
    if not result.ok:
        raise CommandContractError(result.reason)
    return result.to_dict()


def run_python_command(
    contract: CommandContract,
    api_call: Callable[[], bool],
    *,
    options: Mapping[str, Any],
    satisfied_dependencies: Iterable[str] = (),
) -> dict[str, Any]:
    result = evaluate_command_result(
        contract,
        api_success=api_call(),
        options=options,
        satisfied_dependencies=satisfied_dependencies,
    )
    return python_return_or_raise(result)
