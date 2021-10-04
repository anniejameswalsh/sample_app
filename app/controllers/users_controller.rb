class UsersController < ApplicationController
  
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :subscribe]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy



  def index
    @users = User.paginate(page: params[:page])
  end
  

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end


  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      #UserMailer.account_activation(@user).deliver_now
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit

  end

  def update
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def subscribe
    Stripe.api_key = 'sk_test_51Jf4GEFFrya4Rc8JJYaIJX1z554ToSyIu1DWSE50jX6JaWyohBIYJTfuzpyYX4PrtbMVDiJ4iQSU3QxvfxJ9hJzH00sZW9uM0i'

    intent = Stripe::PaymentIntent.create({
      amount: 1099,
      currency: 'usd',
      # Verify your integration in this guide by including this parameter
      metadata: {integration_check: 'accept_a_payment'},
    })
    if @user.subscribe
      flash[:success] = "You've been subscribed!"
      redirect_to @user
    else
      render 'edit'
    end
  end


  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, 
                                        :password_confirmation)

    end

    # before filters
    

    # confirms the correct user
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    # confirms an admin user
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
