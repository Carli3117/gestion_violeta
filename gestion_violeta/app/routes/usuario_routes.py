# app/routes/usuario_routes.py
from flask import Blueprint, render_template, request, redirect, session, url_for, jsonify, flash
from werkzeug.security import check_password_hash, generate_password_hash

from app.crud.usuario_crud import (
    crear_usuario, actualizar_usuario, eliminar_usuario,
    listar_usuarios, obtener_usuario_por_correo
)
from app.crud.roll_crud import listar_rolls

usuario_bp = Blueprint('usuario', __name__, url_prefix='/usuarios')

def es_admin():
    return session.get('user_rol') == 1  # Ajusta si tu rol admin es otro ID

# --- Vista de usuarios (ADMIN) ---
@usuario_bp.route('/')
def vista_usuarios():
    usuarios = listar_usuarios()
    roles = listar_rolls()
    return render_template(
        'usuario/usuarios_view.html',
        usuarios=usuarios,
        roles=roles,
        es_admin=es_admin()
    )

# --- Nuevo usuario (ADMIN) ---
@usuario_bp.route('/nuevo', methods=['POST'])
def nuevo_usuario():
    nombre = request.form.get('nombre', '')
    correo = request.form.get('correo', '')
    password = request.form.get('password', '')
    idroll = request.form.get('idroll', '1')

    if not (nombre and correo and password and idroll):
        flash('Faltan datos obligatorios.', 'warning')
        return redirect(url_for('usuario.vista_usuarios'))

    usuario = crear_usuario(nombre, correo, password, idroll)
    if not usuario:
        flash('Ya existe un usuario con ese correo.', 'danger')
        return redirect(url_for('usuario.vista_usuarios'))

    flash('Usuario creado correctamente.', 'success')
    return redirect(url_for('usuario.vista_usuarios'))

# --- Editar usuario (ADMIN) ---
@usuario_bp.route('/editar/<int:idusuario>', methods=['POST'])
def editar_usuario(idusuario):
    datos = request.form.to_dict()
    # Normalizar 'activo' y 'password' aquí también es válido, pero lo hace el CRUD.
    estado, _ = actualizar_usuario(idusuario, datos, es_admin=es_admin())

    if estado == 'ok':
        flash('Usuario actualizado correctamente.', 'success')
    elif estado == 'duplicate_email':
        flash('El correo ya está en uso por otro usuario.', 'danger')
    elif estado == 'not_found':
        flash('Usuario no encontrado.', 'warning')
    else:
        flash('No se pudo actualizar el usuario.', 'danger')

    return redirect(url_for('usuario.vista_usuarios'))

# --- Eliminar usuario (ADMIN) ---
@usuario_bp.route('/eliminar/<int:idusuario>', methods=['POST'])
def eliminar_usuario_view(idusuario):
    if eliminar_usuario(idusuario):
        flash('Usuario eliminado correctamente.', 'success')
    else:
        flash('No se pudo eliminar el usuario.', 'danger')
    return redirect(url_for('usuario.vista_usuarios'))

# --- REST API: lista usuarios JSON ---
@usuario_bp.route('/api', methods=['GET'])
def api_listar():
    # Asumiendo que tu modelo Usuario tiene método as_dict()
    return jsonify([u.as_dict() for u in listar_usuarios()])

# =====================
#      LOGIN USUARIO
# =====================
@usuario_bp.route('/login', methods=['GET', 'POST'])
def login():
    error = None
    if request.method == 'POST':
        correo = request.form.get('correo', '')
        password = request.form.get('password', '')

        usuario = obtener_usuario_por_correo(correo)
        if usuario and check_password_hash(usuario.password, password):
            if not usuario.activo:
                error = 'Tu usuario está inactivo.'
            else:
                session['user_id'] = usuario.idusuario
                session['user_nombre'] = usuario.nombre
                session['user_rol'] = usuario.idroll
                return redirect(url_for('usuario.dashboard'))
        else:
            error = 'Credenciales incorrectas'

    return render_template('usuario/login.html', error=error)

# --- Logout ---
@usuario_bp.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('usuario.login'))

# --- Dashboard ---
@usuario_bp.route('/dashboard')
def dashboard():
    return render_template('usuario/dashboard.html')
