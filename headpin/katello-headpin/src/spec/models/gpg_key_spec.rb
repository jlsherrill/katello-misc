#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'spec_helper'

describe GpgKey, :katello => true do
  include OrchestrationHelper
  include AuthorizationHelperMethods

  describe "permission checks" do
    let(:organization) do
        disable_org_orchestration
        Organization.create!(:name => "Duh", :cp_key => "ahaha")
    end

    let(:gpg) {GpgKey.create!(:name => "hazard", :organization => organization, :content => "Barn")}

    describe "check on read operations" do
      [[:gpg, :organizations],[:read, :organizations],[:read, :providers]].each do |(perm, resource)|
        it "user with #{perm} on #{resource} should be allowed to work with gpg" do
          User.current = user_with_permissions{|u| u.can(perm, resource,nil, organization, :all_tags => true)}
          GpgKey.find(gpg.id).should be_readable
          GpgKey.readable(organization).should_not be_empty
          GpgKey.readable(organization).should == [gpg]
        end
      end
      it "user without perms should not  be allowed to work with gpg" do
        User.current = user_without_permissions
        GpgKey.find(gpg.id).should_not be_readable
        GpgKey.readable(organization).should be_empty
      end
    end

    describe "check on write operations" do
      it "user with #{:gpg} on #{:org} should be allowed to work with gpg" do
        User.current = user_with_permissions{|u| u.can(:gpg, :organizations,nil, organization, :all_tags => true)}
        GpgKey.find(gpg.id).should be_manageable
        GpgKey.manageable(organization).should == [gpg]
      end

      it "user without perms should not  be allowed to work with gpg" do
        User.current = user_without_permissions
        GpgKey.find(gpg.id).should_not be_manageable
        GpgKey.manageable(organization).should be_empty
      end
    end

  end

end