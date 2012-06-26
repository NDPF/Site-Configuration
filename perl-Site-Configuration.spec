Summary: a module for reading site-local configuration data
Name: perl-Site-Configuration
Version: 0.03
Release: 1%{?dist}
License: APL 2.0
Group: Development/Libraries
URL: http://www.nikhef.nl/grid/
Source0: Site-Configuration-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
BuildRequires: perl(ExtUtils::MakeMaker)
BuildArch: noarch
Requires:  perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))


%description
Site::Configuration helps to read configuration files that contain site-local
information, in /etc/siteinfo/. This may be used by configuration scripts run
by packages in the post scriptlet. The purpose of this library is to present
a framework to help keep these configuration programs lightweight and portable.

%package VO
Summary: a module for reading the site-local VO configuration
Group: Development/Libraries

%description VO

Site::Configuration::VO helps to read VO specific parameters as set in
the per-VO configuration files in /etc/vo-support/.

%prep
%setup -q -n Site-Configuration-%{version}

%build
%{__perl} Makefile.PL INSTALLDIRS=vendor
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make pure_install PERL_INSTALL_ROOT=$RPM_BUILD_ROOT
find $RPM_BUILD_ROOT -type f -name .packlist -exec rm -f {} ';'
find $RPM_BUILD_ROOT -type d -depth -exec rmdir {} 2>/dev/null ';'
chmod -R u+w $RPM_BUILD_ROOT/*

%check
%if 0%{?fedora}
make test
%endif

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%doc README Changes
%{perl_vendorlib}/Site/Configuration.pm
%{_mandir}/man3/Site::Configuration.3pm*

%files VO
%defattr(-,root,root,-)
%{perl_vendorlib}/Site/Configuration/VO.pm
%{_mandir}/man3/Site::Configuration::VO.3pm*


%changelog
* Fri Jun 22 2012 Dennis van Dok <dennisvd@nikhef.nl> 0.03-1
- Split off VO configuration

* Thu Jun  7 2012 Dennis van Dok <dennisvd@nikhef.nl> 0.02-1
- New version

* Sat Jun  2 2012 Dennis van Dok <dennisvd@nikhef.nl> 0.01-1
- Initial build.


