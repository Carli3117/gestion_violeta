# app.py
from flask import Flask, request, jsonify
from flask_cors import CORS
from config import DB_URI
from db import db
from models import Usuario, Proyecto, Tarea, Estado, Prioridad
from werkzeug.security import check_password_hash
from sqlalchemy import or_
import traceback


app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})
app.config['SQLALCHEMY_DATABASE_URI'] = DB_URI
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db.init_app(app)

@app.route('/login', methods=['POST'])
def login():
    try:
        data = request.get_json(silent=True) or {}
        correo = (data.get('correo') or "").strip()
        password = (data.get('password') or "").strip()

        if not correo or not password:
            return jsonify({'success': False, 'message': 'Faltan credenciales'}), 400

        user = Usuario.query.filter_by(correo=correo, activo=True).first()
        if user and check_password_hash(user.password, password):
            return jsonify({
                'success': True,
                'idusuario': user.idusuario,
                'nombre': user.nombre,
                'correo': user.correo,
                'idroll': user.idroll
            })
        else:
            return jsonify({'success': False, 'message': 'Credenciales inválidas'}), 401
    except Exception as e:
        print("Error en /login:", traceback.format_exc())
        return jsonify({'success': False, 'message': 'Error interno'}), 500

@app.route('/tareas', methods=['GET'])
def listar_tareas():
    q = (request.args.get('q') or '').strip()
    page = int(request.args.get('page', 1))
    page_size = int(request.args.get('page_size', 20))

    query = (
        db.session.query(Tarea)
        .join(Proyecto, Tarea.idproyecto == Proyecto.idproyecto)
        .join(Usuario, Tarea.idusuario_asignado == Usuario.idusuario)
        .join(Estado, Tarea.idestado == Estado.idestado)
        .outerjoin(Prioridad, Tarea.idprioridad == Prioridad.idprioridad)
    )

    if q:
        like = f"%{q}%"
        query = query.filter(
            or_(
                Tarea.titulo.ilike(like),
                Tarea.descripcion.ilike(like),
                Proyecto.nombre_proyecto.ilike(like)  # <- nombre correcto en tu modelo
            )
        )

    total = query.count()

    rows = (query
            .order_by(Tarea.fecha_creacion.desc())
            .offset((page - 1) * page_size)
            .limit(page_size)
            .all())

    items = []
    for t in rows:
        items.append({
            "idtarea": t.idtarea,
            "titulo": t.titulo,
            "descripcion": t.descripcion,
            "estado": (t.estado.nombre_estado if t.estado else "Sin Estado"),
            "prioridad": (t.prioridad.nombre_prioridad if t.prioridad else "media"),
            "fecha_creacion": t.fecha_creacion.isoformat() if t.fecha_creacion else None,
            "proyecto": {
                "idproyecto": t.proyecto.idproyecto if t.proyecto else None,
                "nombre": (t.proyecto.nombre_proyecto if t.proyecto else "Sin Proyecto")
            },
            "asignado": {
                "idusuario": t.usuario_asignado.idusuario if t.usuario_asignado else None,
                "nombre": t.usuario_asignado.nombre if t.usuario_asignado else "",
                "correo": getattr(t.usuario_asignado, "correo", "") if t.usuario_asignado else ""
            }
        })

    return jsonify({
        "success": True,
        "page": page,
        "page_size": page_size,
        "total": total,
        "items": items
    })

if __name__ == "__main__":
    with app.app_context():
        db.create_all()
    app.run(host="0.0.0.0", port=5000, debug=True)
