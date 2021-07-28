#!/bin/sh

function display_platform_selection_menu {
    echo
    echo "What do you need to deploy?"
    echo

    PS3="> "

    select option in "ACI" "Intersight" Quit

    do
        case $option in
            "ACI")
                display_aci_selection_menu
                echo
                break
            ;;
            "Intersight")
                display_intersight_selection_menu
            ;;
            Quit)
                break
            ;;
            *) 
                echo "Invalid option $REPLY"
            ;;
        esac
    done
}

function display_aci_selection_menu {
    echo
    echo "What are you configuring in ACI?"
    echo

    PS3="> "

    select option in "Application Profile" "Access Policies" Quit

    do
        case $option in
            "Application Profile")
                echo "Running ..."
                ./enable_aci_single_bd_single_epg.sh
                echo
                echo
                break
            ;;
            "Access Policies")
                echo "Not yet implemented"
            ;;
            Quit)
            break
            ;;
            *) 
            echo "Invalid option $REPLY"
            ;;
        esac
    done
}


function display_intersight_selection_menu {
    echo "Not yet implemented"
}

display_platform_selection_menu