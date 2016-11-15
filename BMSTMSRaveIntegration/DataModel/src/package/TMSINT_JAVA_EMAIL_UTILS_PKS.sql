-- *****************************************************************************
-- ***                                                                       ***
-- *** Package Body :    tmsint_java_email_utils                             ***
-- ***                                                                       ***
-- *** Date Written: 14 November 2016                                        ***
-- ***                                                                       ***
-- *** Written By:   DBMS Consulting Inc.                                    ***
-- ***                                                                       ***
-- *** Run as:       SYSTEM                                                  ***
-- ***                                                                       ***
-- *** Prerequisite: Oracle User TMSINT application's Java owner             ***
-- ***               must be pre-existing                                    ***
-- ***                                                                       ***
-- *** Description:  This script will create package tmsint_java_email_utils ***
-- ***               which is used for sending emails. This package is owned ***
-- ***               by account TMSINT application's Java owner.             ***
-- ***                                                                       ***
-- *****************************************************************************

CREATE OR REPLACE
PACKAGE tmsint_java_email_utils AUTHID DEFINER
   AS

--    **********************************************
--    *** Extract Data from Client Source System ***
--    **********************************************
      PROCEDURE email
        (pEmailToList    IN  VARCHAR2,
         pEmailCCList    IN  VARCHAR2  DEFAULT NULL,
         pEmailSubject   IN  VARCHAR2,
         pEmailBody      IN  CLOB);

   END tmsint_java_email_utils;

/

SHOW ERRORS ;
EXIT