Periodic tasks / Crontab settings
=================================

With every Flexibility instance comes a default configuration of the crontab according to your PIM version.
As the frequency of those recurring tasks may vary depending the project needs, we do not manage cronjob changes beside the first setup.
A common case is when you upgrade the PIM, you will probably need to update the crontab for the PIM to perform as intended.

.. warning::

    It is the responsibility of the integrator to tune the cronjob according to the project needs. The default cron jobs for an Enterprise Edition PIM are listed in the following :doc:`Cron Jobs section </install_pim/manual/installation_ee_archive>`.

Usage
-----

The cronjobs are launched with the usual `akeneo` user. You can see the crontab using the following command:

.. code-block:: bash

    me@localhost:$ ssh akeneo@my-instance.cloud.akeneo.com
    akeneo@my-instance:$ crontab -l # Show the crontab
    akeneo@my-instance:$ crontab -e # Edit the crontab

If you are not familiar with it, a crontab is a list of commands executed periodically and looks like that:

.. code-block:: bash

    # ┌───────────── minute (0 - 59)
    # │ ┌───────────── hour (0 - 23)
    # │ │ ┌───────────── day of month (1 - 31)
    # │ │ │ ┌───────────── month (1 - 12)
    # │ │ │ │ ┌───────────── day of week (0 - 6) (Sunday to Saturday;
    # │ │ │ │ │                                       7 is also Sunday on some systems)
    # │ │ │ │ │
    # │ │ │ │ │
    # * * * * *  command to execute


SHELL wrapper
-------------

We provide a wrapper in the default crontab that intend to simplify the usage of the crontab for the PIM.
This shell wrapper is defined on top of the crontab with the variable *SHELL* and will take care of prepending the path of the PIM
and the console binary also taking care of the logs. Logs will be written in the PIM logs directory by default with this wrapper.

If you don't want to use this wrapper you can prepend `SHELL=/bin/bash`, for example, before your cronjobs and do any custom implementation.

.. code-block:: bash

    SHELL=“/usr/local/sbin/cron_wrapper.sh”
    MAILTO="projectmanager@acme.com"

    #Ansible: akeneo:rule:run
    15 12,20 * * * akeneo:rule:run --env=prod
    #Ansible: pim:versioning:refresh
    30 16,23 * * * pim:versioning:refresh --env=prod
    #Ansible: akeneo:batch:purge-job-execution
    20 0 1 * * akeneo:batch:purge-job-execution --env=prod
    #Ansible: pimee:project:notify-before-due-date
    20 0 * * * pimee:project:notify-before-due-date --env=prod
    #Ansible: akeneo:connectivity-audit:update-data
    1 0 * * * akeneo:connectivity-audit:update-data --env=prod
    #Ansible: pim:asset:send-expiration-notification
    0 1 * * * pim:asset:send-expiration-notification --env=prod
    #Ansible: pimee:project:recalculate
    0 2 * * * pimee:project:recalculate --env=prod
    #Ansible: pimee:franklin-insights:fetch-products
    */30 * * * * pimee:franklin-insights:fetch-products --env=prod
    #Ansible: akeneo:reference-entity:refresh-records --all
    0 23 * * * akeneo:reference-entity:refresh-records --all --env=prod
    #Ansible: pimee:sso:rotate-log 10 --env=prod
    4 22 * * * pimee:sso:rotate-log 10 --env=prod
    #Ansible: pim:volume:aggregate --env=prod
    0 23 * * * pim:volume:aggregate --env=prod
    #Ansible: pimee:data-quality-insights:schedule-periodic-tasks --env=prod
    15 0 * * * pimee:data-quality-insights:schedule-periodic-tasks --env=prod
    #Ansible: pimee:data-quality-insights:evaluate-products --env=prod
    */30 * * * * pimee:data-quality-insights:evaluate-products --env=prod
    #Ansible: pimee:franklin-insights:quality-highlights:push-structure-and-products
    15 0,12 * * * pimee:franklin-insights:quality-highlights:push-structure-and-products --env=prod

    # My custom jobs
    SHELL=/bin/bash

    0 2 * * * sh /home/akeneo/bin/mysscript.sh
    15 2 * * * python /home/akeneo/bin/myexport.py

Mail notification
-----------------

In case you want to be notified when something wrong happens doing a task execution you can specify an email address via the *MAILTO* variable.
The default value will be set to the administrator email but you can change it to fit your needs (by using a mailing list for example).

Execution time
--------------

We would like to remind you that all our servers are configured with UTC time, don't forget to convert the time from the desired local time to UTC time.

.. warning::

    If your country uses "Daylight Saving Time" and you want to take that into consideration on your cronjob you can follow the following trick:

.. code-block:: bash

    # The command /foo/bar will be executed at 02:15 UTC or 03:15 UTC
    # depending on the DST settings of the CET timezone
    15 2 * * * [ `TZ=CET date +\%Z` = CET ] && sleep 3600; /foo/bar
