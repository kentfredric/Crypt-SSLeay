package Crypt::SSLeay;

use strict;
use vars qw(@ISA $VERSION %CIPHERS);

require DynaLoader;

@ISA = qw(DynaLoader);
$VERSION = '0.25';

bootstrap Crypt::SSLeay $VERSION;

use vars qw(%CIPHERS);
%CIPHERS = (
   'NULL-MD5'     => "No encryption with a MD5 MAC",
   'RC4-MD5'      => "128 bit RC4 encryption with a MD5 MAC",
   'EXP-RC4-MD5'  => "40 bit RC4 encryption with a MD5 MAC",
   'RC2-CBC-MD5'  => "128 bit RC2 encryption with a MD5 MAC",
   'EXP-RC2-CBC-MD5' => "40 bit RC2 encryption with a MD5 MAC",
   'IDEA-CBC-MD5' => "128 bit IDEA encryption with a MD5 MAC",
   'DES-CBC-MD5'  => "56 bit DES encryption with a MD5 MAC",
   'DES-CBC-SHA'  => "56 bit DES encryption with a SHA MAC",
   'DES-CBC3-MD5' => "192 bit EDE3 DES encryption with a MD5 MAC",
   'DES-CBC3-SHA' => "192 bit EDE3 DES encryption with a SHA MAC",
   'DES-CFB-M1'   => "56 bit CFB64 DES encryption with a one byte MD5 MAC",
);


# A xsupp bug made this nessesary
sub Crypt::SSLeay::CTX::DESTROY  { shift->free; }
sub Crypt::SSLeay::Conn::DESTROY { shift->free; }
sub Crypt::SSLeay::X509::DESTROY { shift->free; }

1;

__END__

=head1 NAME

  Crypt::SSLeay - OpenSSL glue that provides LWP https support

=head1 SYNOPSIS

  lwp-request https://www.nodeworks.com

  use LWP::UserAgent;
  my $ua = new LWP::UserAgent;
  my $req = new HTTP::Request('GET', 'https://www.nodeworks.com');
  my $res = $ua->request($req);
  print $res->code."\n";

  # PROXY SUPPORT
  $ENV{HTTPS_PROXY} = 'http://proxy_hostname_or_ip:port';

  # PROXY_BASIC_AUTH
  $ENV{HTTPS_PROXY_USERNAME} = 'username';
  $ENV{HTTPS_PROXY_PASSWORD} = 'password';  

  # DEFAULT SSL VERSION
  $ENV{HTTPS_VERSION} = '3';

  # CLIENT CERT SUPPORT
  $ENV{HTTPS_CERT_FILE} = 'certs/notacacert.pem';
  $ENV{HTTPS_KEY_FILE}  = 'certs/notacakeynopass.pem';

=head1 DESCRIPTION

This perl module provides support for the https
protocol under LWP, so that a LWP::UserAgent can 
make https GET & HEAD & POST requests. Please see
perldoc LWP for more information on POST requests.

The Crypt::SSLeay package contains Net::SSL,
which is automatically loaded by LWP::Protocol::https
on https requests, and provides the necessary SSL glue
for that module to work via these deprecated modules:

   Crypt::SSLeay::CTX
   Crypt::SSLeay::Conn
   Crypt::SSLeay::X509

Work on Crypt::SSLeay has been continued only to
provide https support for the LWP - libwww perl
libraries.  If you want access to the OpenSSL 
API via perl, check out Sampo's Net::SSLeay.

=head1 INSTALL

=head2 OpenSSL

You must have OpenSSL or SSLeay installed before compiling 
this module.  You can get the latest OpenSSL package from:

  http://www.openssl.org

When installing openssl make sure your config looks like:

  > ./config --openssldir=/usr/local/openssl
 or
  > ./config --openssldir=/usr/local/ssl

 then
  > make
  > make test
  > make install

This way Crypt::SSLeay will pick up the includes and 
libraries automatically.  If your includes end up
going into a separate directory like /usr/local/include,
then you may need to symlink /usr/local/openssl/include
to /usr/local/include

=head2 Crypt::SSLeay

The latest Crypt::SSLeay can be found at your nearest CPAN,
and also:

  http://www.perl.com/CPAN-local/modules/by-module/Crypt/

Once you have downloaded it, Crypt::SSLeay installs easily 
using the make or nmake commands as shown below.  

  > perl Makefile.PL
  > make
  > make test
  > make install

  * use nmake for win32

  !!! NOTE for Win32 users, few people seem to be able to build
  W  Crypt::SSLeay successfully on that platform.  You don't need
  I  to because ActiveState has already compiled it for you,
  N  and is available for their perl builds 618 & 522 as a ppm
  3  install.  It may also be available for their latest build.
  2  Keywords: WinNT, Win95, Win98, 95, 98, NT, 2000
  !!!          Please see http://www.activestate.com/

=head1 PROXY SUPPORT

For proxying web requests, like with LWP::UserAgent->proxy(), or
lwp-request C<-p> ..., you need to set an environment variable
HTTPS_PROXY to your proxy server & port, as in:

  # PROXY SUPPORT
  $ENV{HTTPS_PROXY} = 'http://proxy_hostname_or_ip:port';
  $ENV{HTTPS_PROXY} = '127.0.0.1:8080';

Use of the HTTPS_PROXY environment variable in this way 
is compatible with LWP::UserAgent->env_proxy() usage.

If we could find the current LWP object executing while
in Net::SSL context, then we could support proxy() method
too, but it does not seem feasible to do so at this time.

Basic auth credentials to the proxy server can be provided 
this way:

  # PROXY_BASIC_AUTH
  $ENV{HTTPS_PROXY_USERNAME} = 'username';
  $ENV{HTTPS_PROXY_PASSWORD} = 'password';  

=head1 CLIENT CERTIFICATE SUPPORT

Certificate support is new, provided by patches from Tobias Manthey.

PEM encoded certificate and private key files may be used like this:

  $ENV{HTTPS_CERT_FILE} = 'certs/notacacert.pem';
  $ENV{HTTPS_KEY_FILE}  = 'certs/notacakeynopass.pem';

You may test your files with the ./net_ssl_test program
by issuing a command like:

  ./net_ssl_test -cert=certs/notacacert.pem -key=certs/notacakeynopass.pem -d GET $HOST_NAME

=head2 Creating a Test Certificate

To create simple test certificates with openssl, you may:

     /usr/local/openssl/bin/openssl req -config /usr/local/openssl/openssl.cnf -new -days 365 -newkey rsa:1024 -x509 -keyout notacakey.pem -out notacacert.pem 

To remove the pass phrase from the key file, execute this:
     /usr/local/openssl/bin/openssl rsa -in notacakey.pem -out notacakeynopass.pem

=head1 SSL VERSIONS

Crypt::SSLeay tries very hard to connect to ANY SSL web server
trying to accomodate servers that are buggy, old or simply
not standards compliant.  To this effect, this module will
try SSL connections in this order:

  SSL v23  - should allow v2 & v3 servers to pick their best type
  SSL v3   - best connection type
  SSL v2   - old connection type

Unfortunately, some servers seem not to handle a reconnect
to SSL v3 after a failed connect of SSL v23 is tried,
so you may set before using LWP or Net::SSL:

  $ENV{HTTPS_VERSION} = 3;

so that a SSL v3 connection is tried first.  At this time
only a SSL v2 connection will be tried after this, as the 
connection attempt order remains unchanged by this setting.

=head1 COMPATIBILITY

 This module has been compiled on the following platforms:

 PLATFORM	CPU 	SSL		PERL	 VER	DATE		WHO
 --------	--- 	---		----	 ---	----		---
 Solaris 2.7    SPARC   OpenSSL 0.9.6   5.00503  .22    2001-03-01      Dave Paris
 Linux 2.2.14   x86	OpenSSL 0.9.6	5.00503	 .21	2001-01-10	Joshua Chamas
 WinNT SP6 	x86	OpenSSL 0.9.4	5.00404	 .21	2001-01-10	Joshua Chamas
 AIX 4.3.2	RS/6000	OpenSSL 0.9.6	5.6.0	 .19	2001-01-08	Peter Heimann
 Solaris 2.6	x86	OpenSSL 0.9.5a	5.00501	 .17    2000-09-04	Joshua Chamas
 Linux 2.2.12   x86     OpenSSL 0.9.5a  5.00503	 .16	2000-07-13      David Harris
 FreeBSD 3.2	?x86	OpenSSL 0.9.2b	5.00503	 ?      1999-09-29	Rip Toren
 Solaris 2.6	?Sparc	OpenSSL 0.9.4	5.00404	 ?      1999-08-24	Patrick Killelea
 FreeBSD 2.2.5	x86	OpenSSL 0.9.3	5.00404	 ?      1999-08-19	Andy Lee
 Solaris 2.5.1	USparc	OpenSSL 0.9.4	5.00503	 ?      1999-08-18	Marek Rouchal
 Solaris 2.6	x86	SSLeay 0.8.0	5.00501	 ?      1999-08-12	Joshua Chamas
 Linux 2.2.10	x86 	OpenSSL 0.9.4	5.00503	 ?      1999-08-11	John Barrett
 WinNT SP4	x86	SSLeay 0.9.2	5.00404	 ?      1999-08-10	Joshua Chamas

=head1 BUILD NOTES

=head2 Win32, WinNT, Win2000, can't build

If you cannot get it to build on your windows box, try 
ActiveState perl, at least their builds 522 & 618 are
known to have a ppm install of Crypt::SSLeay available.
Please see http://www.activestate.com for more info.

=head2 AIX 4.3.2 - Symbol Error: __umoddi3 : referenced symbol not found

The __umoddi3 problem applies here as well when compiling with gcc.

Alternative solution:
In Makefile.PL, prepend C<-L>/usr/local/<path to your gcc lib>/<version>
to the $LIBS value. Add after line 82:

 $LIBS = '-L' . dirname(`gcc -print-libgcc-file-name`) . ' ' . $LIBS;

=head2 Solaris x86 - Symbol Error: __umoddi3 : referenced symbol not found

 Problem:

On Solaris x86, the default PERL configuration, and preferred, is to use
the ld linker that comes with the OS, not gcc.  Unfortunately during the 
OpenSSL build process, gcc generates in libcrypto.a, from bn_word.c,
the undefined symbol __umoddi3, which is supposed to be later resolved
by gcc from libgcc.a

The system ld linker does not know about libgcc.a by default, so 
when building Crypt::SSLeay, there is a linker error for __umoddi3

 Solution:

The fix for this symlink your libgcc.a to some standard directory
like /usr/local/lib, so that the system linker, ld, can find
it when building Crypt::SSLeay.  

=head2 FreeBSD 2.x.x / Solaris - ... des.h:96 #error _ is defined ...

If you encounter this error: "...des.h:96: #error _ is
defined, but some strange definition the DES library cannot handle
that...," then you need to edit the des.h file and comment out the 
"#error" line.

Its looks like this error might be common to other operating
systems, and that occurs with OpenSSL 0.9.3.  Upgrades to
0.9.4 seem to fix this problem.

=head1 NOTES

Many thanks to Gisle Aas for the original writing of 
this module and many others including libwww for perl.  
The web will never be the same :)

Ben Laurie deserves kudos for his excellent patches
for better error handling, SSL information inspection,
and random seeding.

James Woodyatt is a champ for finding a ridiculous memory
leak that has been the bane of many a Crypt::SSLeay user.

Thanks to Bryan Hart for his patch adding proxy support,
and thanks to Tobias Manthey for submitting another approach.

Thanks to Alex Rhomberg for Alpha linux ccc patch.

Thanks to Tobias Manthey for his patches for client 
certificate support.

=head1 SUPPORT

For OpenSSL and Crypt::SSLeay support, please email the 
openssl user mailing list at openssl-users@openssl.org  

Emails to the list sent with at least Crypt::SSLeay in the 
subject line will be responded to more quickly by myself.
Please make the subject line informative like

  Subject: [Crypt::SSLeay] compile problems on Solaris

This module was originally written by Gisle Aas, and I am
now maintaining it.

=head1 COPYRIGHT

 Copyright (c) 1999-2001 Joshua Chamas.
 Copyright (c) 1998 Gisle Aas.

This program is free software; you can redistribute 
it and/or modify it under the same terms as Perl itself. 

=cut
