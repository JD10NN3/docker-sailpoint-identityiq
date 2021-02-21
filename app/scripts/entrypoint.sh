#!/bin/bash

echo "Waiting for database server '${MYSQL_HOST}'..."
while ! mysqladmin ping -h${MYSQL_HOST} -u${MYSQL_ROOT_USER} -p${MYSQL_ROOT_PASSWORD} --silent ; do
    sleep 1s
done

echo "Check if we need to execute SQL scripts..."
export CHECK_DATABASE_EXIST=$(mysqlshow -h${MYSQL_HOST} -u${MYSQL_ROOT_USER} -p${MYSQL_ROOT_PASSWORD} | grep identityiq)
if [ -z "$CHECK_DATABASE_EXIST" ]
then
    echo "No database found!"
    echo "Creating database schema..."
    mysql -u${MYSQL_ROOT_USER} -p${MYSQL_ROOT_PASSWORD} -h${MYSQL_HOST} < ${CATALINA_HOME}/webapps/identityiq/WEB-INF/database/create_identityiq_tables-*.mysql

    echo "Applying patch to the schema (if provided)..."
    shopt -s nullglob
    for SQL_FILE in ${CATALINA_HOME}/webapps/identityiq/WEB-INF/database/upgrade_identityiq_tables-*.mysql; do
        echo "Executing sql script: ${SQL_FILE}"
        mysql -u${MYSQL_ROOT_USER} -p${MYSQL_ROOT_PASSWORD} -h${MYSQL_HOST} < ${SQL_FILE}
    done
else
	echo "Database exist!";
fi

echo "Adjust iiq.properties to allow communication with the database '${MYSQL_HOST}'"
sed -ri -e "s/mysql:\/\/localhost/mysql:\/\/${MYSQL_HOST}/" ${CATALINA_HOME}/webapps/identityiq/WEB-INF/classes/iiq.properties

echo "Check if we need to make the initial import..."
export CHECK_DATA_EXIST=$(mysql -s -N -h${MYSQL_HOST} -u${MYSQL_ROOT_USER} -p${MYSQL_ROOT_PASSWORD} -e "SELECT EXISTS(SELECT id FROM identityiq.spt_identity LIMIT 1);")
if [ ! -z "$CHECK_DATA_EXIST" ]
then
    echo "Importing init.xml and init-lcm.xml..."
    echo "import init.xml" | ${CATALINA_HOME}/webapps/identityiq/WEB-INF/bin/iiq console
    echo "import init-lcm.xml" | ${CATALINA_HOME}/webapps/identityiq/WEB-INF/bin/iiq console

    echo "Check if a patch was provided"
    PATCH_README=${CATALINA_HOME}/webapps/identityiq/WEB-INF/config/patch/identityiq-*-README.txt
    for f in $PATCH_README; do
        if [ -e "$f" ] 
        then 
            export PATCH_NUMBER=$(echo "${f##*/}" | cut -d '-' -f 2)
            echo "Applying patch ${PATCH_NUMBER}..."
            ${CATALINA_HOME}/webapps/identityiq/WEB-INF/bin/iiq patch "${PATCH_NUMBER}"
        else
            echo "No patch provided"
        fi

        break
    done
else
	echo "Initial data already loaded!";
fi

# Launch tomcat with hosted webapps
/opt/tomcat/bin/catalina.sh run