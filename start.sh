#!/bin/bash

# Display ImpactGaming Banner
show_banner() {
    echo -e "\e[38;5;202m"
    echo "  _____                           _____           _             "
    echo " |_   _|                         /  __ \         | |            "
    echo "   | |  _ __ ___   __ _  __ _   | /  \/ __ _ ___| |_ ___ _ __  "
    echo "   | | | '_ \` _ \ / _\` |/ _\` |  | |    / _\` / __| __/ _ \ '__| "
    echo "  _| |_| | | | | | (_| | (_| |  | \__/\ (_| \__ \ ||  __/ |    "
    echo "  \___/|_| |_| |_|\__,_|\__, |   \____/\__,_|___/\__\___|_|    "
    echo "                         __/ |                                  "
    echo "                        |___/                                   "
    echo -e "\e[34mMaintenance By Impact Gaming\e[0m"
    echo -e "\e[36mThe best Minecraft hosting and premium service\e[0m"
    echo "============================================================"
    echo ""
}

# Error Handling
error_exit() {
    echo -e "\e[31m[ERROR] $1\e[0m" >&2
    exit 1
}

# Server Installation
install_server() {
    case $1 in
        "paper")
            echo "Downloading PaperMC $2..."
            API_URL="https://api.papermc.io/v2/projects/paper/versions/$2"
            BUILD=$(curl -s "$API_URL" | jq '.builds[-1]')
            JAR_NAME="paper-$2-$BUILD.jar"
            curl -o "$SERVER_JARFILE" "$API_URL/builds/$BUILD/downloads/$JAR_NAME" || error_exit "PaperMC download failed"
            ;;
        "purpur")
            echo "Downloading Purpur $2..."
            API_URL="https://api.purpurmc.org/v2/purpur/$2"
            BUILD=$(curl -s "$API_URL" | jq '.builds.latest')
            curl -o "$SERVER_JARFILE" "$API_URL/$BUILD/download" || error_exit "Purpur download failed"
            ;;
        "pufferfish")
            echo "Downloading Pufferfish $2..."
            curl -o "$SERVER_JARFILE" "https://ci.pufferfish.host/job/Pufferfish-$2/lastSuccessfulBuild/artifact/build/libs/Pufferfish-$2.jar" || error_exit "Pufferfish download failed"
            ;;
        "fabric")
            echo "Installing Fabric $2..."
            INSTALLER="https://maven.fabricmc.net/net/fabricmc/fabric-installer/0.11.2/fabric-installer-0.11.2.jar"
            curl -o fabric-installer.jar "$INSTALLER" || error_exit "Fabric installer download failed"
            java -jar fabric-installer.jar server -mcversion "$2" -downloadMinecraft || error_exit "Fabric installation failed"
            rm fabric-installer.jar
            ;;
        "forge")
            echo "Installing Forge $2..."
            INSTALLER="https://maven.minecraftforge.net/net/minecraftforge/forge/$2/forge-$2-installer.jar"
            curl -o forge-installer.jar "$INSTALLER" || error_exit "Forge installer download failed"
            java -jar forge-installer.jar --installServer || error_exit "Forge installation failed"
            rm forge-installer.jar
            mv forge-*.jar "$SERVER_JARFILE"
            ;;
        *) error_exit "Invalid server type: $1" ;;
    esac
}

# Main Execution
main() {
    show_banner
    
    # Auto-install if variables set
    if [ "$AUTO_INSTALL" == "true" ] && [ -n "$SERVER_TYPE" ] && [ -n "$MINECRAFT_VERSION" ]; then
        echo "Running automated installation..."
    else
        echo "Select Server Software:"
        echo "1) PaperMC (Recommended)"
        echo "2) Purpur (Optimized)"
        echo "3) Pufferfish (High Performance)"
        echo "4) Fabric (Modded)"
        echo "5) Forge (Modded)"
        echo -n "Enter choice (1-5): "
        read -r choice

        case $choice in
            1) SERVER_TYPE="paper" ;;
            2) SERVER_TYPE="purpur" ;;
            3) SERVER_TYPE="pufferfish" ;;
            4) SERVER_TYPE="fabric" ;;
            5) SERVER_TYPE="forge" ;;
            *) error_exit "Invalid selection" ;;
        esac

        echo -n "Enter Minecraft version (e.g., 1.20.1): "
        read -r MINECRAFT_VERSION
    fi

    # Install server if JAR doesn't exist
    if [ ! -f "$SERVER_JARFILE" ]; then
        install_server "$SERVER_TYPE" "$MINECRAFT_VERSION"
    fi

    # Start Server
    echo "Starting $SERVER_TYPE server (v$MINECRAFT_VERSION)..."
    java -Xms128M -Xmx${SERVER_MEMORY}M ${JAVA_ARGS} -jar ${SERVER_JARFILE} nogui
}

main "$@"
