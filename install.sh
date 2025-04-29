#!/bin/bash
TAG=installed
if [ -f "$TAG" ]
then
	echo "re-initing and exiting"
	exec bash
	exit 1
fi

# Update package lists
sudo apt-get update

# Install packages listed in the apttools file
while read -r package; do
    if [[ ! -z "$package" && ! "$package" =~ ^# ]]; then
        echo "Installing $package..."
        sudo apt-get install -y "$package"
    fi
done < /home/az/config/apttools

echo "All packages installed!"

# Install and configure Starship
if ! command -v starship &> /dev/null
then
    echo "Installing Starship..."
    curl -fsSL https://starship.rs/install.sh | sh
fi

# Add Starship configuration to shell profiles
echo 'eval "$(starship init bash)"' >> ~/.bashrc

# Ensure .config directory exists and move starship.toml into it
mkdir -p ~/.config
if [ -f starship.toml ]; then
    mv starship.toml ~/.config/
fi

# backup and link
bal () {
	repo=$(pwd)
	mkdir -p $repo/original
	if [ -f ~/$1 ]; then
		mv ~/$1 $repo/original/$1
	fi
	ln -s $repo/$1 ~/$1
}

bal .bash_aliases
bal .gitconfig

touch $TAG
exec bash
