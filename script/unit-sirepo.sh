unit_sirepo_main() {
    docker_unit_begin
    install_download_secret sirepo-local
    if [[ $rabbitmq_host = rabbitmq ]]; then
        docker_unit_add link $rabbitmq_host
    fi
    docker_unit_add volume "$sirepo_db_dir"
    # SIREPO_CELERY_TASKS_CELERY_RESULT_BACKEND=db+postgresql+psycopg2://csruser:csrpass@$postgresql_host/celery_sirepo
    docker_unit_add env \
        PYKERN_PKDEBUG_REDIRECT_LOGGING=1 \
        PYKERN_PKDEBUG_WANT_PID_TIME=1 \
        PYTHONUNBUFFERED=1 \
        "SIREPO_CELERY_TASKS_BROKER_URL=amqp://guest@$rabbitmq_host//" \
        "SIREPO_SERVER_DB_DIR=$sirepo_db_dir" \
        "PYKERN_PKDEBUG_CONTROL=sirepo"
    docker_unit_add cmd sirepo service uwsgi
    docker_unit_add port "$sirepo_port"
    docker_unit_add env \
        "SIREPO_PKCLI_SERVICE_DB_DIR=$sirepo_db_dir" \
        "SIREPO_PKCLI_SERVICE_IP=0.0.0.0" \
        "SIREPO_PKCLI_SERVICE_PORT=$sirepo_port" \
        SIREPO_PKCLI_SERVICE_PROCESSES=1
        "SIREPO_PKCLI_SERVICE_RUN_DIR=$docker_unit_guest_dir" \
        SIREPO_PKCLI_SERVICE_THREADS=20 \
        SIREPO_SERVER_JOB_QUEUE=Celery \
        "SIREPO_SERVER_BEAKER_SESSION_KEY=sirepo_$bivio_service_channel"
}


        SIREPO_OAUTH_GITHUB_KEY=$sirepo_oauth_github_key
        SIREPO_OAUTH_GITHUB_SECRET=$sirepo_oauth_github_secret
        SIREPO_SERVER_OAUTH_LOGIN=$sirepo_server_oauth_login
        SIREPO_SERVER_BEAKER_SESSION_SECRET=$sirepo_beaker_secret
