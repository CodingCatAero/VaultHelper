#!/bin/bash
yesAnswers=("y" "yes" "Y" "YES" "Yes")
installAnswers=("i" "I" "install" "INSTALL" "Install")
uninstallAnswers=("u" "U" "uninstall" "UNINSTALL" "Uninstall")

checkFailure() {
    if [[ $1 == 0 ]] ;
    then
        printf "\nDone!"
    else
        printf "\nFailed..."
    fi
}

askConfirmation() {
    read -r -p "$1" choice

    for option in "${yesAnswers[@]}" ;
    do
        if [[ $option == "$choice" ]] ;
        then
            choice=1
        fi
    done

    choice=0
}

askInstallUninstall() {
    read -r -p "Would you like to [I]nstall, or [U]ninstall VaultHelper? " choice

    for option in "${installAnswers[@]}" ;
    do
        if [[ $option == "$choice" ]] ;
        then
            choice=1
        fi
    done

    for option in "${uninstallAnswers[@]}" ;
    do
        if [[ $option == "$choice" ]] ;
        then
            choice=2
        fi
    done

    choice=0
}


installProgram() {
    sudo printf ""

    if [[ $? ]] ;
    then
        printf "Creating %s/.local/bin/" "$HOME"
        printf "\n"
        mkdir "$HOME/.local/bin"

        printf "\nDownloading script to %s/.local/bin/" "$HOME"
        curl -s https://raw.githubusercontent.com/CodingCatAero/VaultHelper/refs/heads/main/vaultHelper | sudo tee "$HOME/.local/bin/vaultHelper" &> /dev/null
        checkFailure $?

        printf "\n\nCreating vaultHelper directory in %s/.config/" "$HOME"
        printf "\n"
        mkdir "$HOME/.config/vaultHelper"

        printf "\nDownloading icons to %s/.local/share/icons/hicolor" "$HOME"
        curl -s https://raw.githubusercontent.com/CodingCatAero/VaultHelper/refs/heads/main/Assets/iconPack.tar.gz > "$HOME/Downloads/iconPack.tar.gz"
        sudo tar -xf "$HOME/Downloads/iconPack.tar.gz"  --one-top-level="$HOME"/.local/share/icons/hicolor
        rm "$HOME/Downloads/iconPack.tar.gz" &> /dev/null
        checkFailure $?

        printf "\n\nDownloading desktop file to %s/.local/share/applications/" "$HOME"
        curl -s https://raw.githubusercontent.com/CodingCatAero/VaultHelper/refs/heads/main/Assets/vaultHelper.desktop | sudo tee "$HOME/.local/share/applications/vaultHelper.desktop" &> /dev/null
        checkFailure $?

        printf "\n\nSetting read & executable permissions for the script and desktop file"
        sudo chmod 777 "$HOME/.local/bin/vaultHelper" && sudo chmod 777 "$HOME/.local/share/applications/vaultHelper.desktop"
        checkFailure $?

        printf "\n\nInstalled!!"
    fi
}


uninstallProgram() {
    sudo printf ""

    if [[ $? ]] ;
    then
        askConfirmation "Are you sure you want to uninstall VaultHelper? [y/N] "

        if [[ $choice == 1 ]] ;
        then
            askConfirmation "Would you like to clear the config? [y/N] "

            if [[ $choice == 1 ]] ;
            then
                printf "\nRemoving vaultHelper config from %s/.config/vaultHelper" "$HOME"
                sudo rm -r "$HOME"/.config/vaultHelper &> /dev/null
                checkFailure $?
            fi
            
            printf "\n\nRemoving vaultHelper script from %s/.local/bin/vaultHelper" "$HOME"
            sudo rm "$HOME/.local/bin/vaultHelper" &> /dev/null
            checkFailure $?

            for dir in "$HOME"/.local/share/icons/hicolor/*/ ;
            do
                if [[ $dir =~ ([0-9]+)"x"([0-9]+)"/" ]] ;
                then

                    printf "\n\nRemoving vaultHelper icon from %sapps/" "$dir"
                    sudo rm "$dir"apps/vaultHelper.png &> /dev/null
                    checkFailure $?
                fi
            done

            printf "\n\nRemoving vaultHelper desktop file from %s/.local/share/applications/vaultHelper.desktop" "$HOME"
            sudo rm "$HOME/.local/share/applications/vaultHelper.desktop" &> /dev/null
            checkFailure $?

            printf "\n\nUninstalled!"
        fi
    fi
}

askInstallUninstall

if [[ $choice == 1 ]] ;
then
    installProgram
elif [[ $choice == 2 ]] ;
then
    uninstallProgram
else
    echo "Non-valid input, exiting."
fi
