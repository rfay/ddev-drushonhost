setup() {
  set -eu -o pipefail
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/test-addon-template
  mkdir -p $TESTDIR
  export PROJNAME=test-addon-template
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  tar -zxf ${DIR}/tests/testdata/d10.3.1.tgz
  ddev config --project-name=${PROJNAME}
  ddev start -y >/dev/null
}

health_checks() {
  # Try using drush on host to do a sql command
  curl -L -s --fail -o /tmp/drush https://github.com/drush-ops/drush/releases/download/8.4.12/drush.phar && chmod +x /tmp/drush
  echo "SHOW TABLES;" | /tmp/drush sql-cli

  # Do an import-db and then make sure we can still do SHOW tables.
  ddev import-db --file=${DIR}/tests/testdata/users.sql.gz
  echo "SHOW TABLES;" | /tmp/drush sql-cli
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${DIR}
  ddev restart
  health_checks
}
#
#@test "install from release" {
#  set -eu -o pipefail
#  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
#  echo "# ddev get rfay/ddev-drushonhost with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
#  ddev get rfay/ddev-drushonhost
#  ddev restart >/dev/null
#  health_checks
#}

