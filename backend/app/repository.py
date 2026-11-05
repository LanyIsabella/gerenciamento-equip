from sqlalchemy.orm import Session


# Código anterior, antes da base compartilhada do Repository:
#
# class EquipamentoRepository:
#     def cadastrar(self, dados):
#         equipamento = Equipamento(**dados)
#         try:
#             self.session.add(equipamento)
#             self.session.commit()
#         except Exception:
#             self.session.rollback()
#             raise
#
# Cada Repository repetia o mesmo controle de commit e rollback. Isso não era
# funcional para manutenção: qualquer ajuste transacional precisava ser copiado
# em equipamentos, manutenções e usuários, aumentando o risco de divergência.
class RepositorioBase:
    def __init__(self, session: Session):
        self.session = session

    def _confirmar(self) -> None:
        try:
            self.session.commit()
        except Exception:
            self.session.rollback()
            raise
