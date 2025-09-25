.PHONY: help prod dev test update_database list freeze load-backup \
        docker-image docker-image-nocache docker-container docker-rebuild-all \
        docker-prune-all reset logs psql

# ===== Variables =====
PROD = requirements/production.txt
DEV = requirements/develop.txt
project_name = medical_backoffice
DOCKER_IMAGE = $(project_name):dev

POSTGRES_CONTAINER = $(shell cat .env | grep -w POSTGRES_CONTAINER_DOCKER | cut -d '=' -f 2)
DB_USER = $(shell cat .env | grep -w DB_USER | cut -d '=' -f 2)
DB_NAME = $(shell cat .env | grep -w DB_NAME | cut -d '=' -f 2)

# ===== Help =====
help: ## Mostrar ayuda con todos los comandos disponibles
	@echo "Comandos disponibles:"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ===== Dependencias =====
list: ## Listar dependencias instaladas
	pip freeze

freeze: ## Generar requirements/common.txt y requirements.txt con pip freeze
	pip freeze > requirements/common.txt
	pip freeze > requirements.txt

clean-deps: ## Eliminar todas las dependencias de desarrollo y producción instaladas
	@echo "Eliminando dependencias de producción y desarrollo..."
	@pip uninstall -r $(PROD) -y || true
	@pip uninstall -r $(DEV) -y || true

prod-deps: ## Instalar dependencias de producción
	pip install -r $(PROD)

dev-deps: ## Instalar dependencias de desarrollo
	pip install -r $(DEV)

test: ## Ejecutar tests con coverage
	coverage run manage.py test
	coverage report
	coverage xml

update_database-docker: ## Ejecutar migraciones dentro del contenedor Docker
	@echo "Ejecutando migraciones en el contenedor monolito..."
	docker exec -it $(project_name)-monolith python manage.py makemigrations
	docker exec -it $(project_name)-monolith python manage.py migrate

update_database-local: ## Ejecutar migraciones localmente
	@echo "Ejecutando migraciones localmente..."
	python manage.py makemigrations
	python manage.py migrate

load-backup: ## Cargar backup JSON (ej: make load-backup file=data)
	python manage.py loaddata backup\$(file).json

# ===== Docker =====
docker-image: ## Construir imágenes Docker (usa caché)
	@echo "Construyendo todas las imágenes Docker..."
	@docker-compose build --pull --progress=auto

docker-image-nocache: ## Construir imágenes Docker sin caché
	@echo "Construyendo todas las imágenes desde cero..."
	@docker-compose build --no-cache --pull --progress=auto

docker-container: ## Levantar contenedores (sin rebuild)
	@echo "Levantando todos los servicios (contenedores y volúmenes)..."
	@docker-compose up -d

docker-rebuild-all: ## Levantar contenedores forzando rebuild
	@echo "⚠️ Esto reconstruirá todas las imágenes y levantará los contenedores."
	@read -p "Presiona ENTER para continuar o Ctrl+C para cancelar..." _
	@bash -c '\
		docker-compose up -d --build; \
		echo "✅ Servicios levantados con rebuild." \
	'

docker-prune-all: ## Eliminar recursos no usados (contenedores detenidos, imágenes no usadas, redes y volúmenes)
	@echo "⚠️ Esto eliminará SOLO los recursos no usados por Docker (contenedores detenidos, imágenes no usadas, volúmenes y redes inactivas)."
	@read -p "Presiona ENTER para continuar o Ctrl+C para cancelar..." _
	@bash -c '\
		docker system prune -a --volumes -f; \
		echo "✅ Recursos no usados eliminados." \
	'

docker-reset: ## Reinicio completo del entorno Docker (prune + build sin cache + levantar)
	@echo "⚠️ Esto eliminará TODO el entorno Docker y reconstruirá desde cero."
	@read -p "Presiona ENTER para continuar o Ctrl+C para cancelar..." _
	@bash -c '\
		$(MAKE) docker-prune-all; \
		$(MAKE) docker-image-nocache; \
		$(MAKE) docker-container; \
		echo "✅ Docker reiniciado completamente." \
	'

docker-delete: ## ⚠️ Elimina el entorno Docker (contenedores, imágenes, volúmenes y redes)
	@echo "⚠️ ADVERTENCIA: Esto eliminará TODOS los contenedores, imágenes, volúmenes y redes personalizadas"
	@read -p "Presiona ENTER para continuar o Ctrl+C para cancelar..." _
	@bash -c '\
		docker rm -f $$(docker ps -aq) || true; \
		docker rmi -f $$(docker images -aq) || true; \
		docker volume rm -f $$(docker volume ls -q) || true; \
		docker network rm $$(docker network ls -q | grep -v "bridge\|host\|none") || true; \
		echo "✅ Docker ha sido reiniciado completamente." \
	'


logs: ## Ver logs de docker-compose
	docker-compose logs -f

psql: ## Acceder al contenedor PostgreSQL
	docker exec -it $(POSTGRES_CONTAINER) psql -U $(DB_USER) -d $(DB_NAME)
