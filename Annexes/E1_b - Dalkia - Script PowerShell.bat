@echo off
setlocal

echo -------------------------------------------------------------------
echo PROCEDURE D'INSTALLATION PC NON MANAGE 
echo.
echo.
echo Etape 1 - Nomenclature de l’ordinateur
echo ----------
:: Renommer l'ordinateur
wmic computersystem where name="%computername%" call rename name="NONOSDTGP3F-01"
echo L'ordinateur a été renommé avec succès! Un redemarrage sera necessaire à la fin.
echo -------------------------------------------------------------------
echo.
echo.
echo.
echo Etape 2 - Compte et séparation des droits
echo ----------
set /p adminpass=Entrez le mot de passe administrateur : 

:: Création du compte administrateur local
net user "Admin_sletellier" %adminpass% /add
:: Attribution du rôle d'administrateur local
net localgroup administrateurs "%computername%\Admin_sletellier" /add
net localgroup utilisateurs "%computername%\Admin_[name]" /delete

:: Création du compte administrateur région
net user "Admin_NO" "[mdpADMIN]" /add
:: Attribution du rôle d'administrateur région
net localgroup administrateurs "%computername%\Admin_NO" /add
net localgroup utilisateurs "%computername%\Admin_NO" /delete
echo Comptes utilisateurs crees avec succes!
echo -------------------------------------------------------------------