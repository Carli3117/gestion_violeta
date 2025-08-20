# app/crud/usuario_crud.py
from app import db
from app.models import Usuario
from werkzeug.security import generate_password_hash

def crear_usuario(nombre, correo, password, idroll, activo=True):
    # Evitar correo duplicado
    if Usuario.query.filter_by(correo=correo).first():
        return None

    usuario = Usuario(
        nombre=nombre.strip(),
        correo=correo.strip().lower(),
        password=generate_password_hash(password),
        idroll=int(idroll),
        activo=bool(activo)
    )
    db.session.add(usuario)
    db.session.commit()
    return usuario

def obtener_usuario_por_id(idusuario):
    return Usuario.query.get(idusuario)

def obtener_usuario_por_correo(correo):
    return Usuario.query.filter_by(correo=correo.strip().lower()).first()

def listar_usuarios():
    return Usuario.query.order_by(Usuario.idusuario.asc()).all()

def actualizar_usuario(idusuario, datos, es_admin=False):
    """
    datos puede incluir: nombre, correo, idroll, activo ('True'/'False' o bool), password (texto).
    - La contraseña solo se actualiza si es_admin y no está vacía.
    - 'activo' se convierte a bool real.
    - Si 'correo' ya existe en otro usuario, no actualiza y devuelve ('duplicate', usuario).
    """
    usuario = Usuario.query.get(idusuario)
    if not usuario:
        return ('not_found', None)

    # Validación de correo duplicado si viene en datos
    if 'correo' in datos:
        nuevo_correo = datos['correo'].strip().lower()
        existe = Usuario.query.filter(Usuario.correo == nuevo_correo, Usuario.idusuario != idusuario).first()
        if existe:
            return ('duplicate_email', usuario)

    # Actualizaciones campo a campo
    for clave, valor in list(datos.items()):
        if clave == 'password':
            # Solo admin y si no está vacío
            if es_admin and valor and valor.strip():
                usuario.password = generate_password_hash(valor.strip())
            # No sobreescribir con vacío
        elif clave == 'activo':
            # Convertir string 'True'/'False' o bool a bool real
            if isinstance(valor, str):
                usuario.activo = valor.strip().lower() == 'true'
            else:
                usuario.activo = bool(valor)
        elif clave == 'idroll':
            usuario.idroll = int(valor)
        elif clave == 'correo':
            usuario.correo = valor.strip().lower()
        elif hasattr(usuario, clave):
            setattr(usuario, clave, valor.strip() if isinstance(valor, str) else valor)

    db.session.commit()
    return ('ok', usuario)

def eliminar_usuario(idusuario):
    usuario = Usuario.query.get(idusuario)
    if usuario:
        db.session.delete(usuario)
        db.session.commit()
        return True
    return False
