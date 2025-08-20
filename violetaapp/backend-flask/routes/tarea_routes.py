from flask import Blueprint, jsonify
from models import Tarea

tarea_bp = Blueprint('tarea', __name__, url_prefix='/tareas')

@tarea_bp.route('/', methods=['GET'])
def listar_tareas():
    try:
        tareas = Tarea.query.order_by(Tarea.fecha_creacion.desc()).all()

        resultado = []
        for t in tareas:
            resultado.append({
                'idtarea': t.idtarea,
                'titulo': t.titulo,
                'descripcion': t.descripcion,
                'estado': t.estado,
                'prioridad': t.prioridad,
                'fecha_creacion': t.fecha_creacion.isoformat() if t.fecha_creacion else None,
                'proyecto': {
                    'idproyecto': t.proyecto.idproyecto if t.proyecto else None,
                    'nombre': t.proyecto.nombre if t.proyecto else ""
                },
                'asignado': {
                    'idusuario': t.asignado.idusuario if t.asignado else None,
                    'nombre': t.asignado.nombre if t.asignado else "",
                    'correo': t.asignado.correo if t.asignado else ""
                }
            })

        return jsonify({'success': True, 'total': len(resultado), 'items': resultado})

    except Exception as e:
        import traceback
        print("Error en listar_tareas:", traceback.format_exc())
        return jsonify({'success': False, 'message': 'Error interno'}), 500
