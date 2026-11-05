from sqlalchemy.orm import Session


class RepositorioBase:
    def __init__(self, session: Session):
        self.session = session

    def _confirmar(self) -> None:
        try:
            self.session.commit()
        except Exception:
            self.session.rollback()
            raise
