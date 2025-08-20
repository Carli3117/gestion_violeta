# app/routes/historial_routes.py
from flask import Blueprint, render_template, request, redirect, url_for, jsonify
from app.crud.historial_crud import listar_historiales, crear_historial, actualizar_historial, eliminar_historial

historial_bp = Blueprint('historial', __name__, url_prefix='/historial')

@historial_bp.route('/')
def vista_historial():
    historiales = listar_historiales()
    return render_template('dashboard/historial/historial_view.html', historiales=historiales)

@historial_bp.route('/nuevo', methods=['POST'])
def nuevo_historial():
    datos = request.form.to_dict()
    crear_historial(**datos)
    return redirect(url_for('historial.vista_historial'))

@historial_bp.route('/editar/<int:idhistorial>', methods=['POST'])
def editar_historial(idhistorial):
    datos = request.form.to_dict()
    actualizar_historial(idhistorial, datos)
    return redirect(url_for('historial.vista_historial'))

@historial_bp.route('/eliminar/<int:idhistorial>', methods=['POST'])
def eliminar_historial_view(idhistorial):
    eliminar_historial(idhistorial)
    return redirect(url_for('historial.vista_historial'))

# API
@historial_bp.route('/api', methods=['GET'])
def api_listar():
    return jsonify([h.as_dict() for h in listar_historiales()])
