#!/usr/bin/env perl

use strict;
use warnings;

use inc::Module::Install 0.91;

use Module::Install::AuthorRequires 0.02;
use Module::Install::ReadmeFromPod 0.06;
use Module::Install::Repository 0.06;
use Module::Install::ExtraTests 0.006;

name 'Catalyst-Plugin-LanguagePrefix';
all_from 'lib/Catalyst/Plugin/LanguagePrefix.pm';
readme_from 'lib/Catalyst/Plugin/LanguagePrefix.pm';
auto_set_repository;

requires 'Catalyst' => '5.80013';
requires 'Catalyst::Plugin::I18N' => '0.09';

#FIXME remove unused test modules
test_requires 'Test::Most' => '0.21';
test_requires 'Test::More' => '0.92';
test_requires 'Test::Differences' => '0.4801';
test_requires 'Test::Deep' => '0.103';
test_requires 'Test::Warn' => '0.21';
test_requires 'Test::Most' => '0.21';
test_requires 'Catalyst::Test' => 0;

author_requires 'Test::Pod' => '1.22';
author_requires 'Test::Pod::Coverage' => '1.08';
author_requires 'Pod::Coverage' => '0.18';

extra_tests;

auto_install;

WriteAll;
