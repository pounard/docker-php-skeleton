#!/bin/bash
# To activate debug information:
# export DEBUG=1
# export SHELL_DEBUG=1

export UID=$(id -u)
export GID=$(id -g)

log() {
    echo "$@">&2;
}

warn() {
    log "warning: $@";
}

die() {
    log "critical: $@";
    exit 1;
}

debug() {
    if [[ -n $DEBUG ]];then
        log "debug: $@";
    fi
}

DEBUG=${DEBUG-${DEBUG}}
SHELL_DEBUG=${SHELL_DEBUG-${SHELLDEBUG}}
if [[ -n $SHELL_DEBUG ]]; then set -x; fi

REALPATH="`dirname $(realpath "$0")`"
ENVFILE="${REALPATH}/.env"

debug "REALPATH: '$REALPATH'";
debug "ENVFILE: '$ENVFILE'";

if [[ ! -e "$ENVFILE" ]]; then
    warn "file '$ENVFILE' does not exists.";
    warn "script requires at least the PROJECT_NAME env var to be set.";
    if [[ -e "$ENVFILE.dist" ]]; then
        warn "found '$ENVFILE.dist', copying as '$ENVFILE'.";
        cp "$ENVFILE.dist" "$ENVFILE"
        source "$ENVFILE"
    fi
else
    source "$ENVFILE"
fi

if [[ -z "$PROJECT_NAME" ]]; then
    die "PROJECT_NAME variable not found in either environment or .env file.";
fi
debug "PROJECT_NAME: '$PROJECT_NAME'";

if [[ -z "$APP_ENV" ]]; then
    die "APP_ENV variable not found in either environment or .env file.";
fi
debug "APP_ENV: '$APP_ENV'";

COMPOSE_FILE="${REALPATH}/docker-compose-${APP_ENV}.yaml";
if [[ ! -e $COMPOSE_FILE ]]; then
    debug "COMPOSE_FILE: file does not exist: '$COMPOSE_FILE'";
    COMPOSE_FILE="${REALPATH}/docker-compose.yaml";
fi
if [[ ! -e $COMPOSE_FILE ]]; then
    COMPOSE_FILE="${REALPATH}/docker-compose.yml";
    if [[ ! -e $COMPOSE_FILE ]]; then
        die "Could not find any of ${REALPATH}/docker-compose.{yml,yaml}";
    fi
fi
debug "COMPOSE_FILE: '$COMPOSE_FILE'";

do_docker_compose() {
    debug "running docker-compose -p $PROJECT_NAME $@";
    docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME $@;
}

do_usage() {
    echo "Usage:";
    echo "  ./control.sh up [CONTAINER_NAME, ...]";
    echo "  ./control.sh down [CONTAINER_NAME, ...]";
    echo "  ./control.sh restart [CONTAINER_NAME, ...]";
    echo "  ./control.sh ps";
    echo "Maintainance:";
    echo "  ./control.sh exec CONTAINER_NAME COMMAND";
    echo "  ./control.sh shell CONTAINER_NAME";
    echo "  ./control.sh pull";
    echo "  ./control.sh build -- <docker compose options>";
    exit 1;
}

do_up() {
    do_docker_compose up -d "$@";
}

do_down() {
    do_docker_compose stop -- "$@";
}

do_restart() {
    do_down $@
    do_up $@
}

do_pull() {
    do_docker_compose pull "$@"
}

do_shell() {
    if [[ -z "$1" ]]; then
        die "missing CONTAINER_NAME argument"
    fi
    local container="$1";
    shift;
    do_docker_compose exec -ti "$container" /bin/bash "$@"
}

do_exec() {
    if [[ -z "$1" ]]; then
        die "missing CONTAINER_NAME argument"
    fi
    local container="$1";
    if [[ -z "$@" ]]; then
        die "missing COMMAND argument"
    fi
    shift;
    do_docker_compose exec "$container" "$@"
}

do_ps() {
    do_docker_compose exec ps "$@"
}

do_build() {
    do_docker_compose up -d --build --remove-orphans --force-recreate
}

do_main() {
    local action=${1-};
    debug "action: $action";

    shift; # Remote $action from args.

    case $action in
        "build") do_build "$@";;
        "down") do_down "$@";;
        "exec") do_exec "$@";;
        "ps") do_ps "$@";;
        "pull") do_pull "$@";;
        "restart") do_restart "$@";;
        "shell") do_shell "$@";;
        "up") do_up "$@";;
        *) do_usage;;
    esac
}

cd "$REALPATH";
do_main "$@";

exit 0;
