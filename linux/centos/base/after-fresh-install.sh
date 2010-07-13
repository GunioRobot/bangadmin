# Things to do after fresh install of CentOS

# update
yum update

# Install vim-enhanced
yum install vim-enhanced
# Add alias vi=vim in /root/.bashrc
echo "alias vi='vim'"  > ~/.bashrc

# Configure repositories
# Install essential software
yum install htop


# Install development packages
yum install gcc kernel-devel kernel-headers

