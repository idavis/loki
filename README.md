Loki
====

Loki is designed to help clean up your profile and move custom functionality to where it belongs ... In your repo

Now, when you ```cd``` (```Set-Location```) into a directory with a Loki file present, it will create a dynamic PowerShell module based on that file and load it into your session. When you ```cd``` into another folder with a Loki file, your old module is unloaded and the new module is loaded in it's place.

Remember to export the functions/variables that you want available in your Loki config file.
