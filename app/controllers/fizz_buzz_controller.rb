class FizzBuzzController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    return unless params[:number].present?

    number = params[:number].to_i
    @result = case
              when number % 15 == 0 then "FizzBuzz"
              when number % 3  == 0 then "Fizz"
              when number % 5  == 0 then "Buzz"
              else number.to_s
              end
  end

  private

  def has_required_roles? = true
end
