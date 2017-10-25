require 'pg'
require 'pg_hstore'

module DBAccess
  def connect_db(dbname)
    user = URL.include?('knife') ? 'docker' : DB_CONF['user']
    pswd = URL.include?('knife') ? '' : DB_CONF['pswd']
    port = URL.include?('knife') ? DB_CONF['port'] : '6432'
    PG::Connection.new(host, port, '', '', dbname, user, pswd)
  end

  def db_access(dbname, field = 'id')
    response = connect_db(dbname).exec(self)
    if response.cmd_tuples.zero?
      'не найден'
    else
      response[0][field]
    end
  end

  def auth_token(user_id)
    cmd = "SELECT url_auth_token FROM public.users where id=#{user_id}"
    cmd.db_access(db_name('users'),'url_auth_token')
  end

  def company_id(name)
    cmd = "SELECT id FROM public.companies where name='#{name}'"
    cmd.db_access(db_name('companies'))
  end

  def user_id(value)
    cmd =
        if value.include?('@')
          "SELECT users.id FROM public.users where email='#{value}'"
        else
          "SELECT user_id FROM public.user_profiles where name='#{value}'"
        end
    cmd.db_access(db_name('users'))
  end

  def order_(id, field)
    cmd = "SELECT #{field} FROM orders.orders where id=#{id}"
    cmd.db_access(db_name('orders'), field)
  end

  private

  def db_name(table)
    if URL.include?('pulscen.ru')
      case table
        when 'orders' then 'cosmos_test'
        when 'users', 'companies' then 'pulscen_test'
        else ''
      end
    else
      case table
        when 'orders' then 'docker_orders'
        when 'users', 'companies' then 'docker'
        else ''
      end
    end
  end

  def host
    if URL.include?('pulscen.ru')
      stand_number = URL.gsub(/[a-z.-]/, '')
      "pc#{stand_number}-db-t.pc#{stand_number}-t.railsc.ru"
    else
      URL
    end
  end
end
