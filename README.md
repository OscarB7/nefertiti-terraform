[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]


# Nefertiti with Terraform in OCI

## About The Project

This project uses [Terraform](https://www.terraform.io/intro) to run [Nefertiti](https://github.com/svanas/nefertiti) on an **always-free tier** instance in the [Oracle Cloud Infrastructure](https://www.oracle.com/cloud/free/) (OCI).

With some parameters, you can apply the Terraform project to create a VCN, subnet, routing table, security list, and instance in OCI. The server will run the `bootstrap.tftpl` script on boot. This script will update the server, create a dot-env file with environment variables, clone this project, and run Nefertiti in a Docker container.

**Advice:** proceed with caution! Use `test=true` and/or `read-only credentials` during the initial setup until you are comfortable with the expected behavior; then remove these safeguards to proceed. Remember, **you are the only one responsible for the outcome**.

*Always-free resources will be used if they are available in your account. See more details in [this](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm) page.*


## Table of Contents

- [About The Project](#about-the-project)
- [Table of Contents](#table-of-contents)
- [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Setup](#setup)
    - [Installation](#installation)
    - [Destroy Resources](#destroy-resources)
- [Usage](#usage)
    - [SSH to the Server](#ssh-to-the-server)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)


## Getting Started

The goal will be to run an OCI instance with two containers, Nefertiti buy and sell instances.


### Prerequisites

The prerequisites are listed [here](https://github.com/OscarB7/terraform-oci-base-resources#prerequisites).


### Setup

Here we will create the `terraform/terraform.tfvars` file and explain how to obtain all the needed values.

*It is important you do not share these parameters and files for security reasons.*
&nbsp;  

1. OCI authentication.

    Follow these [instructions](https://github.com/OscarB7/terraform-oci-base-resources#setup) to get the value of the variables `oci_region`, `oci_user_ocid`, `oci_tenancy_ocid`, `oci_fingerprint`, `oci_private_key_base64`, and `your_home_public_ip`.

2. Clone this project to your machine.

    ```shell
    git clone https://github.com/OscarB7/nefertiti-terraform.git
    ```

3. Create SSH keys.

    You need these to SSH to the server.  
    You probably can run this commands in your own machine. Here, for the sake of simplicity, you will launch an Ubuntu container, install OpenSSH, generate a SSH key pair (`id_rsa` and `id_rsa.pub`), and copy those files to your machine (run lines one by one).

    ```shell
    # run the container and access it
    docker run -it --name temp --user root ubuntu:latest bash
    
    # install openssh
    apt update && apt install -y openssh-client

    # create ssh keys
    ssh-keygen -t rsa -b 4096
    # accept default values by using 'enter' (no password/passphrase)

    exit

    # copy the keys from the container to your machine
    docker container cp temp:/root/.ssh/id_rsa .
    docker container cp temp:/root/.ssh/id_rsa.pub .

    docker rm -f temp
    ```

4. Create the `terraform/terraform.tfvars` file.

    ```shell
    # from step 1
    oci_region                   = "<'region' from step 1>"
    oci_user_ocid                = "<'user' from step 1>"
    oci_tenancy_ocid             = "<'tenancy' from step 1>"
    oci_fingerprint              = "<'fingerprint' from step 1>"
    oci_private_key_base64       = "<base64 one-line string from step 1>"
    your_home_public_ip          = "<public IP address of your home from step 1>"

    ssh_public_key               = "<the content of the file 'id_rsa.pub' created in step 4>"
    use_reserved_public_ip       = false
    docker_compose_version       = "2.1.1"
    docker_network_range         = "10.7.0.0/16"
    docker_compose_network_range = "10.7.107.0/24"

    # from Nefertiti documentation
    nefertiti_version = "latest"
    test              = "false"
    api_key           = "**********"
    api_secret        = "**********"
    api_passphrase    = "**********"
    exchange          = "GDAX"
    price             = "5"
    dca               = "true"
    debug             = "true"
    ignore            = "USDT_USD,UST_USDT,USDT_USDC"
    market            = "all"
    quote             = "USDT"
    repeat            = "1"
    top               = "1"
    volume            = "10"
    agg               = ""
    devn              = ""
    dip               = ""
    dist              = ""
    earn              = ""
    hold              = ""
    min               = ""
    mult              = ""
    notify            = ""
    pip               = ""
    sandbox           = ""
    signals           = ""
    size              = ""
    stoploss          = ""
    strict            = ""
    valid             = ""
    
    # Base/Shared resources (OPTIONAL)
    oci_vcn_id              = "<ID of an already existing VCN in case you want to use it; otherwise, a new one will be created>"
    oci_internet_gateway_id = "<ID of an already existing internet gateway in case you want to use it; otherwise, a new one will be created>"
    oci_route_table_id      = "<ID of an already existing route table in case you want to use it; otherwise, a new one will be created>"
    oci_security_list_id    = "<ID of an already existing security list in case you want to use it; otherwise, a new one will be created>"
    oci_subnet_id           = "<ID of an already existing subnet in case you want to use it; otherwise, a new one will be created>"
    oci_image_id            = "<ID of an already existing image in case you want to use it; otherwise, a new one will be created>"
    ```

    Parameters:

    - **oci_region**: [*REQUIRED*]  
        Region of your OCI account.  
        `region` parameter from the Configuration File in step 2.iv.
    - **oci_user_ocid**: [*REQUIRED*]  
        User ID of your OCI account.  
        `user` parameter from the Configuration File in step 2.iv.
    - **oci_tenancy_ocid**: [*REQUIRED*]  
        Tenancy ID of your OCI account.  
        `tenancy` parameter from the Configuration File in step 2.iv.
    - **oci_fingerprint**: [*REQUIRED*]  
        The fingerprint of your OCI API Key.  
        `region` parameter from the Configuration File in step 2.iv.
    - **oci_private_key_base64**: [*REQUIRED*]  
        One-line base64 string of the OCI private key downloaded in step 2.iii.  
        This value comes from step 3.
    - **your_home_public_ip**: [*REQUIRED*]  
        Public IP of your home.  
        This value comes from step 6.
    - **ssh_public_key**: [*REQUIRED*]  
        SSH public key.  
        This value comes from the content of the `id_rsa.pub` file created in step 5.
    - **use_reserved_public_ip**: [*Default:* `false`]  
        Create a reserved public IP, which is an independent resource from the instance.  
        If set to `true`, this IP will be attached to the instance; therefore, if the instance is recreated, the public IP will not change.  
        If set to `false`, the public IP will be created with the instance.
    - **docker_compose_version**: [*Default:* `2.1.1`]  
        Docker Compose version to be installed in the OCI instance.
    - **docker_network_range**: [*Default:* `10.7.0.0/16`]  
        IP range of Docker in the OCI instance.
    - **docker_compose_network_range**: [*Default:* `10.7.107.0/24`]  
        IP range of the Docker Compose network, where the containers will run.
    - **nefertiti_version**: [*Default:* `latest`]  
        Version of Nefertiti.  
        It must be a valid tag. Check them [here](https://github.com/svanas/nefertiti/tags).

    &nbsp;  
    From here, refer to the Nefertiti documentation on this [link](https://github.com/svanas/nefertiti/wiki/Getting-Started) and this [one](https://medium.com/nefertiticryptobot/introducing-nefertiti-a-simple-crypto-trading-bot-b078898fa164).  

    - **test**: [*Default:* `true`]  
    - **api_key**: [*REQUIRED*]  
    - **api_secret**: [*REQUIRED*]  
    - **api_passphrase**: [*REQUIRED*]  
    - **exchange**: [*REQUIRED*]  
    - **price**: [*REQUIRED*]  
    - **dca**: [*Default:* `true`]  
    - **debug**: [*Default:* `true`]  
    - **ignore**: [*Default:* `USDT_USD,UST_USDT,USDT_USDC`]  
    - **market**: [*Default:* `all`]  
    - **quote**: [*Default:* `USDT`]  
    - **repeat**: [*Default:* `1`]  
    - **top**: [*Default:* `1`]  
    - **volume**: [*Default:* `10`]  
    - **agg**: [*Default:* `Empty`]  
    - **devn**: [*Default:* `Empty`]  
    - **dip**: [*Default:* `Empty`]  
    - **dist**: [*Default:* `Empty`]  
    - **earn**: [*Default:* `Empty`]  
    - **hold**: [*Default:* `Empty`]  
    - **min**: [*Default:* `Empty`]  
    - **mult**: [*Default:* `Empty`]  
    - **notify**: [*Default:* `Empty`]  
    - **pip**: [*Default:* `Empty`]  
    - **sandbox**: [*Default:* `Empty`]  
    - **signals**: [*Default:* `Empty`]  
    - **size**: [*Default:* `Empty`]  
    - **stoploss**: [*Default:* `Empty`]  
    - **strict**: [*Default:* `Empty`]  
    - **valid**: [*Default:* `Empty`]  


    &nbsp;  
    Example (**do not use these values**):

    ```shell
    # from step 1
    oci_region             = "us-ashburn-1"
    oci_user_ocid          = "ocid1.user.oc1..aaa...wmpxt"
    oci_tenancy_ocid       = "ocid1.tenancy.oc1..aaa...dnkxd"
    oci_fingerprint        = "17:a8:...:01:c4"
    oci_private_key_base64 = "AS0tZS2CR3dJT4BQUkl...ZAS3tLS4="
    your_home_public_ip    = "123.123.123.123/32"

    ssh_public_key         = "ssh-rsa AAAAB3NzaC1...Elzyar4w== root@c14cb235dae5"
    use_reserved_public_ip = false

    # from Nefertiti documentation
    test           = "false"
    api_key        = "3c...92"
    api_secret     = "Ee...Jg=="
    api_passphrase = "wv...n"
    exchange       = "GDAX"
    price          = "5"

    # Base/Shared resources (OPTIONAL)
    # in case you created the base resources already with the project terraform-oci-base-resources,
    # see the local_variables from output, e.g., local_oci_vcn_id
    oci_vcn_id              = "ocid1.vcn.oc1.iad.am...wa"
    oci_internet_gateway_id = "ocid1.internetgateway.oc1.iad.aa...ea"
    oci_route_table_id      = "ocid1.routetable.oc1.iad.aa...xq"
    oci_security_list_id    = "ocid1.securitylist.oc1.iad.aa...da"
    oci_subnet_id           = "ocid1.subnet.oc1.iad.aa...pq"
    ```

### Installation

Now that you have completed the [setup](#setup), you can deploy the project to OCI with Terraform.

Follow these [instructions](https://github.com/OscarB7/terraform-oci-base-resources#installation) to create the resources in OCI with Nefertiti running in an instance.

After applying the project, you will see the public IP of your instance in the variable `instance_public_ip` in the Terraform output. For example:

```shell
...
Apply complete! Resources: ...

Outputs:
...
instance_public_ip = "157.157.157.157"
...
```


### Destroy Resources

Follow these [instructions](https://github.com/OscarB7/terraform-oci-base-resources#destroy-resources) to destroy the resources created in the [installation](#installation) step.


## Usage

At this point, you have launched a server in OCI, running one sell and one buy instances of Nefertiti.

### SSH to the Server

You can SSH to the server if you need to troubleshoot. Use the following credentials from your home.

```shell
Hostname: <'instance_public_ip' from the 'installation' section>
Username: ubuntu
Private key: <use 'id_rsa', created in 'setup' section>
```

**Note** there is no `password` since it authenticates with a private key.

You can use [Putty](https://www.putty.org/) on Windows or these commands on a Linux terminal where you saved the `id_rsa` file:

```shell
chmod 0600 id_rsa
ssh ubuntu@<'instance_public_ip'> -i id_rsa
```

Example:

```shell
chmod 0600 id_rsa
ssh ubuntu@157.157.157.157 -i id_rsa

# once connected to the server, you can list the containers
sudo su
cd /opt/nefertiti-terraform/
ls -a
docker ps

# access the sell container, where nefertiti is running
docker exec -it nefer-sell sh
# ...
exit

# now you are back to the OCI server
```


## Roadmap

See the [open issues](https://github.com/OscarB7/nefertiti-terraform/issues) for a complete list of proposed features (and known issues).


## Contributing

Contributions make the open-source community a great place to learn, inspire, and create. Any improvement you add is greatly appreciated.

Please fork this repo and create a pull request if you have any suggestions. You can also open an issue with the tag `enhancement`.
Don't forget to give the project a star! Thanks again!

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a pull request


## License

Distributed under the MIT License. See `LICENSE.txt` for more information.


## Contact

Oscar Blanco - [Twitter @OsBlancoB](https://twitter.com/OsBlancoB) - [LinkedIn][linkedin-url]

Project Link: [https://github.com/OscarB7/nefertiti-terraform](https://github.com/OscarB7/nefertiti-terraform)



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/OscarB7/nefertiti-terraform.svg?style=for-the-badge
[contributors-url]: https://github.com/OscarB7/nefertiti-terraform/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/OscarB7/nefertiti-terraform.svg?style=for-the-badge
[forks-url]: https://github.com/OscarB7/nefertiti-terraform/network/members
[stars-shield]: https://img.shields.io/github/stars/OscarB7/nefertiti-terraform.svg?style=for-the-badge
[stars-url]: https://github.com/OscarB7/nefertiti-terraform/stargazers
[issues-shield]: https://img.shields.io/github/issues/OscarB7/nefertiti-terraform.svg?style=for-the-badge
[issues-url]: https://github.com/OscarB7/nefertiti-terraform/issues
[license-shield]: https://img.shields.io/github/license/OscarB7/nefertiti-terraform.svg?style=for-the-badge
[license-url]: https://github.com/OscarB7/nefertiti-terraform/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/oscar-blanco-b75842132
