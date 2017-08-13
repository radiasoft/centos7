#!/bin/bash
#
# Install perl-modules on clean CentOS 7
#
# Usage: curl radia.run | bash -s centos7 \
#     perl-modules

perl_modules_main() {
    if (( $EUID != 0 )); then
        install_err 'must be run as root'
    fi
    local x=(
        git
        postgresql-server

        gcc-c++
        postgresql-devel
        mod_perl
        xapian-core-devel
        rpm-build

        perl-Algorithm-Diff
        perl-Archive-Zip
        perl-BSD-Resource
        perl-BerkeleyDB
        perl-Business-ISBN
        perl-Business-ISBN-Data
        perl-CPAN
        perl-Class-Load
        perl-Class-Load-XS
        perl-Class-Singleton
        perl-Convert-ASN1
        perl-Crypt-CBC
        perl-Crypt-DES
        perl-Crypt-Eksblowfish
        perl-Crypt-IDEA
        perl-Crypt-OpenSSL-RSA
        perl-Crypt-OpenSSL-Random
        perl-Crypt-RC4
        perl-Crypt-SSLeay
        perl-DBD-Pg
        perl-DBI
        perl-Data-OptList
        perl-Date-Manip
        perl-DateTime
        perl-DateTime-Locale
        perl-DateTime-TimeZone
        perl-Devel-Leak
        perl-Devel-Symdump
        perl-Device-SerialPort
        perl-Digest-HMAC
        perl-Digest-MD4
        perl-Digest-Perl-MD5
        perl-Digest-SHA1
        perl-Email-Abstract
        perl-Email-Address
        perl-Email-Date-Format
        perl-Email-MIME
        perl-Email-MIME-ContentType
        perl-Email-MIME-Encodings
        perl-Email-MessageID
        perl-Email-Reply
        perl-Email-Send
        perl-Email-Simple
        perl-Encode-Detect
        perl-Encode-Locale
        perl-Error
        perl-File-MMagic
        perl-HTML-Form
        perl-HTML-Parser
        perl-HTML-Tagset
        perl-HTTP-Cookies
        perl-HTTP-Date
        perl-HTTP-Message
        perl-HTTP-Negotiate
        perl-IO-Multiplex
        perl-IO-Socket-INET6
        perl-IO-Socket-SSL
        perl-IO-String
        perl-IO-stringy
        perl-Image-Size
        perl-LDAP
        perl-LWP-MediaTypes
        perl-LWP-Protocol-https
        perl-List-MoreUtils
        perl-MIME-Types
        perl-MIME-tools
        perl-MRO-Compat
        perl-Mail-DKIM
        perl-Mail-SPF
        perl-MailTools
        perl-Math-Random-ISAAC
        perl-Module-Implementation
        perl-Module-Runtime
        perl-Mozilla-CA
        perl-Net-CIDR-Lite
        perl-Net-DNS
        perl-Net-DNS-Resolver-Programmable
        perl-Net-Daemon
        perl-Net-HTTP
        perl-Net-IP
        perl-Net-SSLeay
        perl-Net-Server
        perl-NetAddr-IP
        perl-OLE-Storage_Lite
        perl-Package-DeprecationManager
        perl-Package-Stash
        perl-Package-Stash-XS
        perl-Params-Classify
        perl-Params-Util
        perl-Params-Validate
        perl-Parse-RecDescent
        perl-PathTools
        perl-Perl4-CoreLibs
        perl-PlRPC
        perl-Return-Value
        perl-Socket6
        perl-Sub-Exporter
        perl-Sub-Install
        perl-Sub-Uplevel
        perl-Sys-Hostname-Long
        perl-Template-Toolkit
        perl-TermReadKey
        perl-Test-Exception
        perl-Test-Fatal
        perl-Test-MockObject
        perl-Test-Requires
        perl-Test-Simple
        perl-Test-WWW-Selenium
        perl-Text-CSV
        perl-TimeDate
        perl-Try-Tiny
        perl-URI
        perl-WWW-RobotRules
        perl-XML-LibXML
        perl-XML-NamespaceSupport
        perl-XML-Parser
        perl-XML-SAX
        perl-XML-Simple
        perl-XML-XPath
        perl-YAML
        perl-YAML-Syck
        perl-libwww-perl
    )
    yum install -y "${x[@]}"
    install_download src/ctime.patch | (
        cd /
        patch -fp0
    )
    install_tmp_dir
    umask 022
    (
        install_download src/gmp-6.0.0a.tar.bz2 | tar xjf -
        cd gmp-6.0.0/demos/perl
        install_download src/gmp-6.0.0.patch | patch -p0
        perl Makefile.PL
        make install
    )
    (
        centos7_install_file root/.cpan/CPAN/MyConfig.pm
        cpan install OLLY/Search-Xapian-1.2.22.0.tar.gz
    )
}
