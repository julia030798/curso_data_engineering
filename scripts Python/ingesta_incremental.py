import snowflake.connector
from faker import Faker
from datetime import datetime, timedelta
import random

# Configuración de Snowflake
snowflake_config = {
    'user': 'Alumno6',
    'password': 'Mipelusa2012!',
    'account': 'civicapartner.west-europe.azure',
    'warehouse': 'WH_CURSO_DATA_ENGINEERING',
    'database': 'ALUMNO6_DEV_BRONZE_DB',
    'schema': 'SQL_SERVER_DBO',
    'role': 'CURSO_DATA_ENGINEERING_2023'
}

# Configuración de Faker
fake = Faker()

# Función para generar datos aleatorios de promociones
def generate_random_promo():
    promo_ids = ['task-force', 'instruction set', 'leverage', 'Optional', 'Mandatory', 'Digitized']

    return {
        'promo_id': random.choice(promo_ids),  # Varía entre los valores especificados
        'discount': random.randint(1, 100),
        'status': random.choice(['active', 'inactive']),
        '_fivetran_deleted': None,
        '_fivetran_synced': datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S.%f')[:-3] + ' -00:00'
    }

# Función para insertar datos en Snowflake
def insert_data_into_snowflake(promo_data):
    connection = snowflake.connector.connect(**snowflake_config)

    try:
        with connection.cursor() as cursor:
            cursor.execute(
                "INSERT INTO ALUMNO6_DEV_BRONZE_DB.SQL_SERVER_DBO.PROMOS (PROMO_ID, DISCOUNT, STATUS, _FIVETRAN_DELETED, _FIVETRAN_SYNCED)"
                "VALUES (%s, %s, %s, %s, %s)",
                (
                    promo_data['promo_id'],
                    promo_data['discount'],
                    promo_data['status'],
                    promo_data['_fivetran_deleted'],
                    promo_data['_fivetran_synced']
                )
            )

    finally:
        connection.close()

# Número de nuevas promociones a añadir
num_new_promos = 2

# Generar y cargar nuevas promociones
for n in range(num_new_promos):
    promo_data = generate_random_promo()
    insert_data_into_snowflake(promo_data)
    print(f"Promoción insertada: {promo_data}")

print("Ingesta incremental simulada completa.")