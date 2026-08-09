@echo off
setlocal

:menu
echo -------------------------------------------------------------------
echo PROCEDURE D'INSTALLATION PC NON MANAGE 
echo -----------------
echo -- Script menu --
echo -----------------
echo.
echo 1 - Nomenclature de l ordinateur
echo 2 - Compte et separation des droits
echo 3 - Installation de l'antivirus McAfee
echo 4 - Windows Update
echo 5 - Desinstallation des services Windows par de4faut non utilise
echo 6 - Quitter
echo.
set /p menu="Que voulez vous faire ? [1 a 7]  "
If /i "%menu%"=="1" goto :ETAPE1
If /i "%menu%"=="2" goto :ETAPE2
If /i "%menu%"=="3" goto :ETAPE3
If /i "%menu%"=="4" goto :ETAPE4
If /i "%menu%"=="5" goto :ETAPE5
If /i "%menu%"=="6" goto :END

:ETAPE1
echo Etape 1 - Nomenclature de l’ordinateur
echo ----------
set /p newname=Entrez le nouveau nom d'ordinateur indiqué par l'operateur : 
:: Renommer l'ordinateur
wmic computersystem where name="%computername%" call rename name="%newname%"
echo L'ordinateur a été renommé avec succès! Un redemarrage sera necessaire à la fin.
echo -------------------------------------------------------------------
goto :menu



:ETAPE2
echo Etape 2 - Compte et séparation des droits
echo ----------
set /p user=Entrez le nom d'utilisateur (pnom) : 
set /p pass=Entrez le mot de passe pour l'utilisateur : 
set /p adminpass=Entrez le mot de passe administrateur : 
:: Création du compte utilisateur
net user %user% %pass% /add
:: Attribution du rôle d'utilisateur standard
net localgroup utilisateurs %user% /add

:: Création du compte administrateur
set /a admin=Admin_%user%
net user %admin% %adminpass% /add
:: Attribution du rôle d'administrateur
net localgroup administrateur "%computername%\%admin%" /add
net localgroup utilisateurs "%computername%\%admin%" /delete

:: Création du compte super administrateur
set /a supadmin=AdminNO
set /a suppass=D@lk!a5#9St-A2L/aDm*
net user %supadmin% %suppass% /add
:: Attribution du rôle super administrateur
net localgroup Administrateur "%computername%\%supadmin%" /add
net localgroup utilisateurs "%computername%\%supadmin%" /delete

echo Comptes utilisateurs créés avec succès!
echo -------------------------------------------------------------------
goto :menu



:ETAPE3
echo Etape 3 - Installation de l'antivirus McAfee
echo ----------
echo Lancement du programme ...
echo - Au lancement de l'executable, veillez vous connecter avec votre compte administrateur, puis suivre les etapes indiquees a l'ecran.
echo - Une fois l'installation fini vous pourrez revenir ici.
timeout /t 30 /nobreak
start "" "TrellixSmartInstall.exe"
echo -------------------------------------------------------------------
goto :menu



:ETAPE4
echo Etape 4 - Windows Update
echo ----------
echo Lancement de l'application parametre ...
echo - Verifier que les mises a jour sois en automatique,
echo - Si des mises a jour sont disponible, faitent la,
echo - Une fois fini vous pourrez revenir ici.
timeout /t 30 /nobreak
start "" "ms-settings:windowsupdate"
echo -------------------------------------------------------------------
goto :menu



:ETAPE5
echo Etape 5 - Desinstallation des services Windows par défaut non utilise
echo ----------
echo Lancement du script ...
echo - L'invite de commande vous demandera d'accepter, taper O puis Entrer
echo - Une fois l'installation fini vous pourrez revenir ici.
timeout /t 20 /nobreak
start "" "Disable_Service_Required.bat" -new-window
echo -------------------------------------------------------------------


pause


echo -------------------------------------------------------------------
echo La Procedure d'Installation PC non manage est terminé.
echo Votre ordinateur va redemarrer dans 30 secondes pour appliquer les modifications.
echo -------------------------------------------------------------------
::shutdown -s -t 30
timeout /t 30 /nobreak

:END
endlocal
exit