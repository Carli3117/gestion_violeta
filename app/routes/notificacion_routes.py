from flask import Blueprint, render_template, request, redirect, url_for, jsonify
from app.crud.notificacion_crud import *
from app.crud.tarea_crud import listar_tareas_pendientes

notificacion_bp = Blueprint('notificacion', __name__, url_prefix='/notificaciones')


@notificacion_bp.route('/nuevo', methods=['POST'])
def nueva_notificacion():
    crear_notificacion(**request.form.to_dict())
    return redirect(url_for('notificacion.vista_notificaciones'))

@notificacion_bp.route('/editar/<int:idnotificacion>', methods=['POST'])
def editar_notificacion(idnotificacion):
    datos = request.form.to_dict()
    actualizar_notificacion(idnotificacion, datos)
    return redirect(url_for('notificacion.vista_notificaciones'))

@notificacion_bp.route('/eliminar/<int:idnotificacion>', methods=['POST'])
def eliminar_notificacion_view(idnotificacion):
    eliminar_notificacion(idnotificacion)
    return redirect(url_for('notificacion.vista_notificaciones'))

@notificacion_bp.route('/api', methods=['GET'])
def api_listar():
    return jsonify([n.as_dict() for n in listar_notificaciones()])



@notificacion_bp.route('/')
def vista_notificaciones():
    notificaciones = listar_notificaciones()
    tareas_pendientes = listar_tareas_pendientes()
    return render_template(
        'notificaciones/notificaciones_view.html',
        notificaciones=notificaciones,
        tareas_pendientes=tareas_pendientes
    )
