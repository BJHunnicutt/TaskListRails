class SessionsController < ApplicationController
  def create
    auth_hash = request.env['omniauth.auth']
    # raise
    flash[:notice] = "Login Failed!"  #This is kind of like a cookie or param, it's saved in the background
    return redirect_to root_path unless auth_hash['uid']  # THe return makes it so nothing after this happens

    @user = User.find_by(uid: auth_hash[:uid], provider: 'github')  #specifying both because you could log someone in with the same user id on facebook
    if @user.nil?
      # User doesn't match anything in the DB.
      # Attempt to create a new user.
      @user = User.build_from_github(auth_hash)
      flash[:notice] = "Unable to save the user"
      return render :root_path unless @user.save
    end

    # Save the user ID in the session
    session[:user_id] = @user.id

    flash[:notice] = "Successfully logged in!"
    redirect_to root_path

  end

  def destroy
    session[:user_id] = nil  # Don't want to delete users (usually) for simplicity

    redirect_to root_path
  end
end
