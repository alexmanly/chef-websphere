#
# Cookbook Name:: base-was
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
include_recipe 'base-was::setup-hosts'
include_recipe 'base-was::setup-iptables'
include_recipe 'base-was::setup-partition'
include_recipe 'base-was::install-was'
include_recipe 'base-was::manage-was-profile'
include_recipe 'base-was::audit-was'
