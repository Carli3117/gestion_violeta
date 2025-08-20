from flask import Blueprint, render_template, request, redirect, url_for, jsonify, flash, session
from app.crud.comentario_crud import *
from app.crud.proyecto_crud import listar_proyectos
from app.crud.tarea_crud import listar_tareas, obtener_tarea_por_id, actualizar_tarea
from app.crud.usuario_crud import listar_usuarios
from app.crud.adjunto_crud import listar_adjuntos, crear_adjunto, obtener_adjunto_por_id, eliminar_adjunto
from app.crud.estado_crud import listar_estados
from datetime import datetime
from werkzeug.utils import secure_filename
import os
from uuid import uuid4

comentario_bp = Blueprint('comentario', __name__, url_prefix='/comentarios')

UPLOAD_FOLDER = os.path.join(os.getcwd(), 'uploads_adjuntos')
ALLOWED_EXTENSIONS = {'jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@comentario_bp.route('/', methods=['GET', 'POST'])
def vista_comentarios():
    proyectos = listar_proyectos()
    tareas = listar_tareas()
    usuarios = listar_usuarios()
    adjuntos = listar_adjuntos()
    estados = listar_estados()

    idproyecto = request.args.get('idproyecto', type=int)
    idtarea = request.args.get('idtarea', type=int)
    tareas_filtradas = [t for t in tareas if (not idproyecto or t.idproyecto == idproyecto)]

    comentarios_tarea = []
    tarea_sel = None
    if idtarea:
        tarea_sel = obtener_tarea_por_id(idtarea)
        comentarios_tarea = tarea_sel.comentarios if tarea_sel else []

    now = datetime.now().strftime('%Y-%m-%dT%H:%M')

    # --- REGISTRO DE NUEVO COMENTARIO CON ARCHIVO ---
    if request.method == 'POST':
        form = request.form
        comentario = form.get('comentario')
        idtarea_form = form.get('idtarea')
        idestado = form.get('idestado')
        idusuario = session.get('idusuario') or 1

        # --- MANEJO DE ARCHIVO ADJUNTO ---
        idadjunto = None
        file = request.files.get('adjunto')  # <input name="adjunto">
        if file and file.filename and allowed_file(file.filename):
            os.makedirs(UPLOAD_FOLDER, exist_ok=True)
            unique_prefix = str(uuid4())[:8]
            filename = f"{unique_prefix}_{secure_filename(file.filename)}"
            ruta_archivo = os.path.join(UPLOAD_FOLDER, filename)
            file.save(ruta_archivo)
            adjunto_obj = crear_adjunto(
                ruta_archivo=ruta_archivo,
                tipo=file.mimetype,
                fecha_subida=datetime.now(),
                idusuario=idusuario,
                descripcion='Adjunto de comentario'
            )
            idadjunto = adjunto_obj.idadjunto
        else:
            # Por si se selecciona uno ya existente por id (si tu form lo soporta, opcional)
            idadjunto_form = form.get('idadjunto') or None
            if idadjunto_form and str(idadjunto_form).isdigit():
                idadjunto = int(idadjunto_form)

        fecha_str = form.get('fecha')
        if fecha_str:
            try:
                fecha = datetime.strptime(fecha_str, '%Y-%m-%dT%H:%M')
            except Exception:
                fecha = datetime.now()
        else:
            fecha = datetime.now()

        tarea_actual = obtener_tarea_por_id(idtarea_form)
        if tarea_actual and idestado and str(tarea_actual.idestado) != str(idestado):
            actualizar_tarea(idtarea_form, {"idestado": idestado})

        crear_comentario(
            idtarea=idtarea_form,
            idusuario=idusuario,
            comentario=comentario,
            fecha=fecha,
            idadjunto=idadjunto,
            idestado=idestado
        )
        flash("Comentario agregado correctamente.")
        return redirect(url_for('comentario.vista_comentarios', idproyecto=idproyecto, idtarea=idtarea_form))

    return render_template(
        'comentarios/comentarios_view.html',
        proyectos=proyectos,
        tareas=tareas_filtradas,
        usuarios=usuarios,
        adjuntos=adjuntos,
        estados=estados,
        idproyecto=idproyecto,
        idtarea=idtarea,
        comentarios=comentarios_tarea,
        tarea_sel=tarea_sel,
        now=now
    )

@comentario_bp.route('/editar/<int:idcomentario>', methods=['POST'])
def editar_comentario(idcomentario):
    datos = request.form.to_dict()
    actualizar_comentario(idcomentario, datos)
    return redirect(url_for('comentario.vista_comentarios'))

@comentario_bp.route('/eliminar/<int:idcomentario>', methods=['POST'])
def eliminar_comentario_view(idcomentario):
    # Opcional: elimina adjunto físico también si lo deseas
    comentario = obtener_comentario_por_id(idcomentario)
    if comentario and comentario.idadjunto:
        adjunto = obtener_adjunto_por_id(comentario.idadjunto)
        if adjunto and adjunto.ruta_archivo and os.path.exists(adjunto.ruta_archivo):
            try:
                os.remove(adjunto.ruta_archivo)
            except Exception as e:
                print(f"Error eliminando archivo adjunto: {e}")
        eliminar_adjunto(comentario.idadjunto)
    eliminar_comentario(idcomentario)
    return redirect(url_for('comentario.vista_comentarios'))

@comentario_bp.route('/api', methods=['GET'])
def api_listar():
    return jsonify([c.as_dict() for c in listar_comentarios()])
