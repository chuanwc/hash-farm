# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140402135114) do

  create_table "accounts", force: true do |t|
    t.integer  "coin_id",               null: false
    t.string   "address",    limit: 34, null: false
    t.string   "label",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounts", ["coin_id"], name: "index_accounts_on_coin_id"

  create_table "coins", force: true do |t|
    t.string   "name",                     limit: 64, null: false
    t.string   "code",                     limit: 5,  null: false
    t.integer  "second_per_block",                    null: false
    t.integer  "difficulty_retarget",                 null: false
    t.string   "algo",                     limit: 64, null: false
    t.integer  "block_confirmation",                  null: false
    t.integer  "transaction_confirmation",            null: false
    t.string   "rpc_url",                             null: false
    t.string   "bitcointalk_url"
    t.string   "website"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payouts", force: true do |t|
    t.integer  "transaction_id", null: false
    t.integer  "our_fees",       null: false
    t.integer  "users_amount",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payouts", ["transaction_id"], name: "index_payouts_on_transaction_id"

  create_table "shares", force: true do |t|
    t.integer  "worker_id",                                       null: false
    t.string   "solution",    limit: 64,                          null: false
    t.float    "difficulty",                                      null: false
    t.boolean  "our_result",                                      null: false
    t.boolean  "pool_result"
    t.string   "reason"
    t.boolean  "is_block",                                        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "payout_id"
    t.string   "pool",        limit: 64, default: "CleverMining", null: false
  end

  add_index "shares", ["payout_id"], name: "index_shares_on_payout_id"

  create_table "transactions", force: true do |t|
    t.integer  "coin_id"
    t.string   "raw"
    t.string   "txid"
    t.string   "ourid"
    t.string   "block"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "transactions", ["coin_id"], name: "index_transactions_on_coin_id"

  create_table "users", force: true do |t|
    t.string   "name",         limit: 64
    t.string   "password",     limit: 64
    t.string   "email"
    t.string   "btc_address",  limit: 34,             null: false
    t.boolean  "is_anonymous",                        null: false
    t.boolean  "is_admin",                            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "balance",                 default: 0
  end

  create_table "workers", force: true do |t|
    t.integer  "user_id",                 null: false
    t.string   "name",         limit: 63
    t.boolean  "is_anonymous",            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workers", ["user_id"], name: "index_workers_on_user_id"

end