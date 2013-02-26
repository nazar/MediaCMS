module Admin::OrdersHelper

  def user_column(record)
    record.user.pretty_name unless record.user.blank?
  end

end
