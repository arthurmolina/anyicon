# frozen_string_literal: true

Dummy::Application.routes.draw do
  get "/icons", to: "pages#icons"
  get "/demo", to: "pages#demo"
end
