require 'pg'
require 'pg_hstore'

class PGRead
  def connect_db(dbname)
    user = URL.include?('knife.railsc.ru') ? 'docker' : DBCONF['user']
    pswd = URL.include?('knife.railsc.ru') ? '' : DBCONF['pswd']
    port = URL.include?('knife.railsc.ru') ? DBCONF['port'] : '6432'
    PG::Connection.new(host, port, '', '', dbname, user, pswd)
  end

  def db_access(dbname, fields = ['id'])
    response = connect_db(dbname).exec(self)
    if response.cmd_tuples.zero?
      'не найден'
    else
      temp = []
      fields.each do |field|
        temp << value[0][field]
      end
      temp
    end
  end

  # ('SELECT users.id FROM public.users where email=123456').db_access(dbname)

  def company_id(name)
    cmd = "SELECT id FROM public.companies where name='#{name}'"
    puts cmd
    result(connect_db(db_name('companies')).exec(cmd))
  end

  def user_id(value)
    cmd =
        if value.include?('@')
          "SELECT users.id FROM public.users where email='#{value}'"
        else
          "SELECT user_id FROM public.user_profiles where name='#{value}'"
        end
    puts cmd
    result(connect_db(db_name('users')).exec(cmd))
  end

  def order_(field, id)
    cmd = "SELECT #{field} FROM orders.orders where id=#{id}"
    connect_db(db_name('orders')).exec(cmd)[0][field]
  end

  private

  def result(value)
    res = value.cmd_tuples.zero? ? 'не найден' : value[0]['id']
    puts 'Result: ' + res.to_s
    res
  end

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
