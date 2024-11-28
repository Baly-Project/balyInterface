# Baly Interface Configuration

This document outlines the steps necessary for loading the Baly Digital Gallery onto a new server.
It assumes that you have a fresh instance of Ubuntu 24.04 with a sudo user account. 

Note that this document and workflow was assembled in October 2024. If there is a newer version of Ubuntu, you may need to find new install commands for certain programs. A good place to look for updated information is [GoRails Installation Guides](https://gorails.com/setup/ubuntu/24.04), as well as youtube tutorials for setting up Rails programs.

## Basic Requirements
Thanks to internal configuration files, we don't need to install each and every program that the app relies on. Instead, we download certain core components, such as the database, and a few package managers, like Yarn. These basic end components are:

* Ruby 3.3.0
* MariaDB
* PhpMyAdmin
* Yarn 1.22.22
* Apache2 2.4.58

## Setup Sequence for Ubuntu 24.04

### 1. Install Ruby

Ruby has several installers that will all leave you with an identical ruby version. Which installer to use depends on various bugs you might encounter, but one of them should always work. We found **RVM** (Ruby Version Manager) to work well in this environment, and so use that in the following instructions.

1. Update apt manager
    ```shell
    sudo apt update
    ```
    
2. Install dependencies
    ```sh
    sudo apt install -y autoconf bison build-essential curl g++ gcc git git-core libffi-dev libgdbm-dev libncurses-dev libreadline-dev libsqlite3-dev libssl-dev libxi6 libyaml-dev make sqlite3 xvfb zip zlib1g-dev libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common gnupg2
    ```

3. Prepare for RVM installation
    ```sh
    gpg2 --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB 

    sudo apt-add-repository -y ppa:rael-gc/rvm
    ```

4. Install RVM
    ```sh
    sudo apt install rvm
    ```

5. Configure RVM
    ```sh
    sudo usermod -a -G rvm "$USER"

    source /etc/profile.d/rvm.sh

    mkdir -p ~/.rvm/user/installs

    sudo shutdown -r
    ```

    This last step finishes by scheduling a system reboot one minute after execution. When the reboot occurs it will disconnect you from the server. Wait about a minute after the reboot begins to reconnect and continue

6. Install Ruby

    ```sh
    rvm install 3.3.0
    ```
    Be prepared to wait for this step, it typically takes 15-20 minutes.

7. Check Installation
    
    The ``>>`` symbol shows expected system output. The installation was successful if your output matches this.
    ```sh
    ruby -v

    >> ruby 3.3.0 (2023-12-25 revision 5124f9ac75) [x86_64-linux]


    rvm list

    >> =* ruby-3.3.0 [ x86_64 ]

        # => - current
        # =* - current && default
        #  * - default
    ```

### 2. MariaDB
    
1. Install MariaDB 
    ```sh
    sudo apt install mariadb-server libmariadb-dev
    ```

2. Run setup sequence
    ```sh
    sudo mysql_secure_installation
    ```
    This will launch a dialog. First you will want to press enter when it asks for the root password, and then it will ask the following questions:

    * Switch to unix_socket authentication? [Y/n]

        * Answer "Y""
    * Change the root password? [Y/n]      
        * Answer "Y"
        * Set the root password and save it in the private documentation on Google Drive 
    * Remove anonymous users? [Y/n]
        * Answer "Y"
    * Disallow root login remotely? [Y/n]
        * Answer "n"
    * Remove test database and access to it? [Y/n]
        * If configuring a testing server, answer "n"
        * If configuring the production server, answer "Y"
    * Reload privilege tables now? [Y/n]
        * Answer "n"
3. Setup limited (non-root) database user
    ```sh
    mysql -u root -p
    ```
    This opens a MariaDB console that will prompt you for the root password set above. Inside the console, enter the commands
    ```sql
    CREATE USER 'curator'@'%' IDENTIFIED BY 'FILL_PASSWORD';

    GRANT SELECT, INSERT, CREATE, ALTER, DROP, LOCK TABLES, CREATE TEMPORARY TABLES, DELETE, UPDATE, INDEX, EXECUTE ON *.* TO 'curator'@'%';
    ```
    (substituting FILL_PASSWORD) with the login info contained in the documentation file in the drive. These commands create a non-root user account that corresponds to the login info found in interface/config/database.yml, and is the account that the Rails app will use when interacting with the database.

### 3. Apache2 and PhpMyAdmin
1. Install Apache2
    ```sh
    sudo apt install apache2
    ```

2. Install PhpMyAdmin
    ```sh
    sudo apt install phpmyadmin php php-mbstring php-zip php-gd php-json php-curl

    sudo apt install libapache2-mod-php8.3
    ```
    These commands will prompt for some configuration options, simply press enter at each stage to use the default configuration.

3. Configure Apache2
    ```sh
    sudo nano /etc/apache2/apache2.conf
    ```
    This opens a text file. Scroll down and paste the following line at the very bottom:
    ```sh
    Include /etc/phpmyadmin/apache.conf
    ```
    Then press ctrl-o ctrl-x to save and exit the file.

4. Restart Apache2
    ```sh
    sudo service apache2 restart
    ```

5. Test Apache2
    
    Navigate to ``http://SERVERIPADDRESS/phpmyadmin``

    and you should see a login page that prompts for a username and password. If you are able to log in using the non-root account you created in MariaDB [here (item 3)](#2-mariadb), then Apache2 and PhpMyAdmin are working correctly and you can move on to the next step.

### 4. Yarn
1. Install Yarn via npm
    ```sh
    sudo apt install npm
    sudo npm install --global yarn
    ```

## App Installation and Setup
With all the necessary dependencies in order, we can import the balyInterface folder and automatically install the rest of the dependencies. First we need to register the server with Github.
### 1. Add Server SSH key to Github
    
First, you will need to have a github account with access to the project. Reach out to me (Braeden) or someone else with ownership to grant you collaborator permissions. Once you can access the project with your account, follow the instructions below to allow Github to verify any pushes made from the server.

1. Generate SSH-RSA key
    ```sh
    ssh-keygen -b 4096 -t rsa
    ```

    When you are prompted for a password, leave it blank and press enter. Remeber the name of the file it creates. (Should be .ssh/id_rsa)

2. Copy public key
    ```sh
    cat .ssh/id_rsa.pub
    ```
    This will output the public key. Copy this to your clipboard.

3. Add key to Github account
    
    Open github in a browser, and open your account settings. Locate the item titled 'SSH and GPG Keys' and select it. In the top right corner, click the button titled 'New SSH key'.

    Provide a distinguishing title for the key, (eg. "test-server" or "baly-server") and paste the copied key into the textbox below.

### 2. Clone balyInterface

Locate the green button titled "Code" at [https://github.com/Bubballoo3/balyInterface.git](https://github.com/Bubballoo3/balyInterface.git) and click it to open a dropdown. Make sure the 'ssh' tab is selected and copy the ssh link.

Then, back at the server, enter
```sh
cd
git clone *Pasted SSH Link*
```
replacing \*Pasted SSH Link\* with the one you just copied.

### 3. Prepare Interface application

1. Remove extra files

    The balyInterface folder comes with lots of HTML concept pages and testing code besides the Rails app contained in the 'interface' folder. Since we don't want to store extraneous data, enter the following commands to delete these additional folders.
    ```sh
    rm -r balyInterface/samplePages balyInterface/methodTesting balyInterface/viewer
    ```

2. Load additional dependencies
    ```sh
    cd balyInterface/interface
    yarn install
    bundle install
    ```

3. Create and load database tables
    ```rb
    rails db:create
    rails db:migrate
    ```

4. Compile assets
    ```rb
    rails assets:precompile
    ```

5. Create updatelogs folder and update tables from Digital Kenyon
    ```rb
    mkdir log/updatelogs
    rake record:update 
    ```

6. Test in browser
    ```sh
    rails s -b 0.0.0.0
    ```
    And navigate to `http://SERVERIPADDRESS:3000`. You should land on the Baly Gallery homepage, and if everything looks right, then the installation is complete!

### 4. Firewall Configuration
Now that everything is working properly, we want to establish a firewall to block any unwanted connections to the server. We will use the built in firewall **ufw**. Enter 
```sh
sudo ufw allow OpenSSH
```
Then, if you are making a server for testing, enter
```sh
sudo ufw allow 3000
```
If instead the server is for production, enter 
```sh
sudo ufw allow 80
```

Finally 
```sh
sudo ufw enable
```
to enable the firewall.

