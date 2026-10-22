from dataclasses import dataclass


@dataclass
class ErroDeDominio(Exception):
    """Exceção de negócio sem dependência do framework HTTP."""

    status_code: int
    detail: str

    def __str__(self) -> str:
        return self.detail
