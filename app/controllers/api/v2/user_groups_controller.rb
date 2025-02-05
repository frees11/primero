# frozen_string_literal: true

# User Group CRUD API
class Api::V2::UserGroupsController < ApplicationApiController
  include Api::V2::Concerns::Pagination
  include Api::V2::Concerns::JsonValidateParams
  before_action :load_user_group, only: %i[show update destroy]

  def index
    authorize_index!
    @user_groups = UserGroup.list(current_user, user_group_filters)
    @total = @user_groups.size
    @user_groups = @user_groups.paginate(pagination) if pagination?
  end

  def show
    authorize! :read, @user_group
  end

  def create
    authorize!(:create, UserGroup) && validate_json!(UserGroup::USER_GROUP_FIELDS_SCHEMA, user_group_params)
    @user_group = UserGroup.new_with_properties(user_group_params, current_user)
    @user_group.save!
    status = params[:data][:id].present? ? 204 : 200
    render :create, status:
  end

  def update
    authorize!(:update, @user_group) && validate_json!(UserGroup::USER_GROUP_FIELDS_SCHEMA, user_group_params)
    @user_group.update_properties(user_group_params)
    @user_group.save!
  end

  def destroy
    authorize! :destroy, @user_group
    @user_group.destroy!
  end

  def user_group_params
    @user_group_params ||= params.require(:data).permit(UserGroup.permitted_api_params)
  end

  protected

  def user_group_filters
    {
      managed: params[:managed],
      disabled: params[:disabled]&.values,
      agency_unique_ids: params[:agency_unique_ids]&.values
    }
  end

  def load_user_group
    @user_group = UserGroup.find(record_id)
  end

  def authorize_index!
    return if current_user.managed_report_scope_all?

    authorize!(:index, UserGroup)
  end
end
