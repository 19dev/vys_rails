# Size düşen nedir?

kodlar,

    $ git clone git@github.com:19bal/vys_rails.git
    $ git checkout auth
    $ bundle
    $ rake db:migrate
    $ rails s --binding=192.168.1.2

Url olarak http://192.168.1.2:3000/ girip, giriş ve çıkışı, ayrıca Node:CRUD
işlemlerini sınayın.

# Nasıl?

1) Öncelikle sadece statik sayfaların olduğu commit'i belirleyip ona
anahtarlayalım, https://github.com/19bal/vys_rails/commits/master adresine
girince 12 mart tarihinde benim commit'im olduğunu zannediyorum

- https://github.com/19bal/vys_rails/commit/8a5e8f4898bea4f82ecbd044a14ed127ad967039

Peki, bu commit'e nasıl geri dönüp, onun üzerinde değişiklik yapacağım

    Google: github checkout roolback

ilk stackoverflow girdisi işimi görecek gibi:
http://stackoverflow.com/questions/373812/rollback-file-to-much-earlier-version

Bu dokumana göre `<commit hash>` bilgisine ihtiyacım var ki daha önceden
verdiğim linkin son kısmı,

- https://github.com/19bal/vys_rails/commit/8a5e8f4898bea4f82ecbd044a14ed127ad967039

    $ git checkout 8a5e8f4898bea4f82ecbd044a14ed127ad967039
    $ git checkout -b auth

bu durum için bağımlılıkları ayarlayalım,

    $ bundle
    $ rails s --binding=192.168.1.2

github'a oluşturduğumuz dalı haber verelim,

    $ git push origin auth

2) Bundan sonrasında Authentication, Authorization ve Role tanımlama olacak.
Yardımcı depomuz,

https://github.com/seyyah/auth-demo/

bunun Readme'sinde söylendiği gibi sırayla gideceğiz. Authentication dokumanımız,

https://github.com/seyyah/auth-demo/blob/auth/README.md

VYS ile uyumlu olsun diyerekten `Post` modeli (ki tablo ismi `posts`'dur) yerine
`Node` modelini oluşturacağız. Dolayısıyla bundan sonraki geçişlerde
auth-demo:README dokumanında `Post` yazılanlar `Node` olarak değiştirilerek
ilerlenecektir.

Önce `Node` modelinine ait iskeleti (scaffold) oluşturalım,

    $ rails g scaffold node title:string content:text

oluşturulan veritabanı geçişini (migrasyon) yapalım,

    $ rails db:migrate

bu iki şeyi gerçekleştirdi,

    db/schema.rb
    db/development.sqlite3

bunlardan ilki veritabanı tablosuna ait şemayı tutarken, diğeri sqlite3
veritabanı dosyasıdır. Sunucuyu başlatalım,

    $ rails s --binding=192.168.1.2

url olarak http://192.168.1.2:3000/nodes yazalım. CRUD (Create, Read, Update,
Destroy) imkanıyla başbaşayız. Yani yeni node oluşturabilir (Read), var olanı
okuyabilir (Read), değiştirebilir (Update) ve silebilir (Destroy) olmalısınız.

Bu durumu commitleyelim,

    $ git add .
    $ git commit -a -m "scaffold:node"

Fakat bunun sıkıntısı herkesin buna ulaşabilmesindedir. Şimdi bunu giriş yapmak
zorunda bırakacak forma dönüştüreceğiz.

Bu amaçla önce `User` modelini oluşturalım,

    $ rails g model user username:string password_digest:string

bu model kullanıcı adı (`username`) ve parola (`password_digest`, `password`
değil, onun gizlenmişi/digest) içermektedir. Migrasyonu gerçekleştirelim,

    $ rake db:migrate

Oluşturduğumuz `User` modelinde parolaların şifreli tutulacağı bilgisini
ekleyelim,

    $ vim app/models/user.rb
    has_secure_password

`password` yerine `password_digest` kullanmamızın sebebi buydu.

Bunu commitleyelim,

    $ git add .
    $ git commit -a -m "model:user + secure_password"

Kullanıcının login olup-olmadığı durumunu (state) HTML tutamaz, bu ancak sunucu
veya istemci tarafında özel mekanizmalarla tutulur. Ayrıntı için,

http://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#HTTP_session_state

bakınız. İstemci tarafında oturum (Session) yönetimiyle bu yapılır. Oturum
idaresini kurgulamamız gerekiyor. Oturum açmak için kullanıcı login formu
olacak, bunları idare etmek için controller olacak, arada model olarak ise
`User` modeli ve `session` kullanılacak.

O yüzden sadece oturum kontrolü oluşturacağız,

    $ rails g controller sessions new
      create  app/controllers/sessions_controller.rb
       route  get "sessions/new"
      invoke  erb
      create    app/views/sessions
      create    app/views/sessions/new.html.erb
      [...]

yani `sessions_controller` oluştu, yönlendirme tablosuna url'den `/sessions/new`
istendiğinde (ki bunu daha sonradan `/login` olarak değiştireceğiz) kimin yanıt
vereceği ("sessions#new": `sessions` controlürünün `new` yöntemi ve
`views: new.html.erb` render edilecek) belirlendi ve views şablonu oluşturuldu.

Hem controller hem de views şablondan oluşturulduğundan isteğimizi karşılamıyor.
Önce views ile standart mesaj,

    <h1>Sessions#new</h1>
    <p>Find me in app/views/sessions/new.html.erb</p>

yerine login formunu getirtelim,

    $ vim app/views/sessions/new.html.erb
    <h1>Login</h1>
    <%= form_tag sessions_path do %>
    <div class="field">
      <%= label_tag "Username" %>
      <%= text_field_tag :username, params[:username] %>
    </div>
    <div class="field">
      <%= label_tag :password %>
      <%= password_field_tag :password %>
    </div>
    <div class="actions">
      <%= submit_tag "Login" %>
    </div>
    <% end %>

kullanıcı url'de `http://192.168.1.2:3000/sessions/new` istediğinde (GET)
sessions controller'un `new` yöntemi üzerinden bu form gösterilecek. Burada
url'de istenen pattern alışılagelen bir yapıda değil oturum açmak için genelde
/login linki verilir. Bu ise yönlendirme idarecesinde yapılacak basit bir
değişikliğe bakıyor,

    $ vim config/routes.rb
    resources :sessions
    get "login" => "sessions#new", :as => "login"

bu arada fazlalıklar da çıkarıldı.

Url olarak http://192.168.1.2:3000/login girelim evet form geldi. Formu doldurup
göndermeye çalışınca,

    Unknown action

    The action 'create' could not be found for SessionsController

diyor. Önce bu son halini commitleyelim,

    $ git add .
    $ git commit -a -m "controller:sessions:new"

Şimdi bu hata mesajına el atalım. Ne diyor?

    The action 'create' could not be found for SessionsController

SessionsController'da (app/controllers/sessions_controller.rb dosyasında)
`create` eylemi (action ~ method) tanımsız diyor. Haklı çünkü orada sadece `new`
yöntemi tanımlı, şimdi `create`'ı ekleyelim,

    $ vim app/controllers/sessions_controller.rb
        def create
          user = User.find_by_username(params[:username])
          if user && user.authenticate(params[:password])
            session[:user_id] = user.id
            redirect_to nodes_path
          else
            flash.now.alert = "Invalid username or password"
            render "new"
          end
        end

bununla şunu gerçekleştirmiş olacağız. Login formu doldurulup gönderildiğinde
(PUT; submit) sessions_controller'un `create` yöntemi yanıt verecek. Peki ne
diyor? Bakalım,

    user = User.find_by_username(params[:username])

formdan gelen `username` (`params` değişkeni bu amaçla kullanılır ve sözlük
veriyapısıdır), `User` modeline ait `find_by_username` yöntemi üzerinden `users`
tablosunda ara demektir. Eğer varsa `nill` (C:NULL, Py:None; False) den farklı bir
değer döner.

    if user && user.authenticate(params[:password])

şimdide girilen parolayı şifrele ve kullanıcıya ait parolanın şifreli haliyle
aynı mı (`authenticate` yöntemi bu işi sağlar; başarılı=true) kontrol et. `if`
koşulu doğruysa kullanıcı adı ve parola doğrudur,

    session[:user_id] = user.id

ile oturum yönetimini sağlayan global değişken `session` sözlüğüne  `user_id`
key'li `user.id` değerli girdi yap. Bunu daha sonradan kullanıcının giriş yapıp
yapmadığını sınamak için kullanacağız.

    redirect_to nodes_path

başarılı girişin ardından `nodes_path`'e (`/nodes` url'sine) yönlendir.

    flash.now.alert = "Invalid username or password"

başarısız denemeyse kullanıcıyı uyar. Bu mesajın görülebilmesi için application
layout'una ekleme yapmak gerekecek,

    $ vim app/views/layouts/application.html.erb
        <div class="container" style="margin-bottom: 80px;" >
           <div class="content">
             <div class="row">
               <div class="span9">
                <% [:notice, :error, :alert].each do |level| %>
                  <% unless flash[level].blank? %>
                    <div data-alert="alert" class="alert alert-<%= level %> fade in">
                        <a class="close" data-dismiss="alert" href="#">&times;</a>
                        <%= content_tag :p, simple_format(flash[level]) %>
                    </div>
                   <% end %>
                <% end %>
               </div>
           </div>
        </div>

Tekrar http://192.168.1.2:3000/login url'sini girelim ve formu doldurup
gönderelim, şöyle bir hata mesajıyla karşılaşacağız,

    Gem::LoadError in SessionsController#create
    bcrypt-ruby is not part of the bundle. Add it to Gemfile.

sebebi açık gerekli olan Gem dosyası eklenip, bundle edilmemiş,

    $ vim Gemfile
    gem 'bcrypt-ruby', '~> 3.0.0'
    $ bundle

Bundle işleminin ardından sunucuyu tekrardan başlatın,

    $ rails s --binding=192.168.1.2

Test zamanıdır url'de http://192.168.1.2:3000/login girip formu doldurun,

    Invalid username or password

mesajını alacağız. Çünkü şimdiye kadar `users` tablosuna herhangi bir kullanıcı
eklemiş değiliz,

    $ rails c
    0> User.create(:username => "seyyah", :password => "secret", :password_confirmation => "secret")

kullanıcıyı ekledik tekrar url'de http://192.168.1.2:3000/login girip formu "seyyah:secret"
çiftiyle dolduralım ve submit edelim. Node'ların listelendiği sayfaya ulaşmış
olmalıyız: http://192.168.1.2:3000/nodes. Burada CRUD yapabiliyor olmalısınız.
Authentication aşaması tamamlandı.

Son durumu commitleyelim,

    $ git add .
    $ git commit -a -m "auth:Ok"

Authorization aşamasına geçmeden önce Login ve Logout linklerini ekleyelim.

Önce `current_user` isminde her yerden erişilebilecek bir yardımcı işlev ekleyelim,

    $ vim app/helpers/sessions_helper.rb
    def current_user
      session[:user_id] ? @current_user ||= User.find(session[:user_id]) : nil
    end

bu oturumu kontrol edip, eğer açıksa kullanıcıyı yoksa `nil` döndürecektir.

Şablon sayfasında,

    $ vim app/views/layouts/_header.html.erb
        <div id="session">
            <% if current_user  %>
              Hoşgeldin <b><%= current_user.username %></b> |
              <%= link_to "Çıkış", logout_url %>
            <% else %>
              Giriş yapmamışsınız |
              <%= link_to "Giriş yap", login_url %>
            <% end %>
        </div>

böylelikle `current_user` yöntemi çağrılır,

        <% if current_user  %>

oturum açıldıysa,

       session[:user_id] ? @current_user ||= User.find(session[:user_id]) : nil

Hoşgeldin,


        Hoşgeldin <b><%= current_user.username %></b> |

kullanıcı adı ise `@current_user` değişkeninden gelir. Yöntem üzerinden
değişkenin (ve hatta tablonun sütununa) erişmenin rails'cesi. Çıkış için
`logout_url` sini göstersin istiyoruz, fakat tanımlamadık rails bize şöyle
tepki vererek cevap veriyor,

    NameError in Nodes#index

    Showing /home/seyyah/work/_mutfak/vys_rails/app/views/layouts/_header.html.erb
    where line #4 raised:

    undefined local variable or method `logout_url' for

bunun sebebi buna dair bir yönlendirmemizin olmaması,

    $ vim config/routes.rb
    get "logout" => "sessions#destroy", :as => "logout"

bu ise "sessions#destroy" dan ötürü SessionsController'da `destroy` yöntemini
gerektirir,

    $ vim app/controllers/sessions_controller.rb
    def destroy
      session[:user_id] = nil
      redirect_to root_url
    end

logout et,

        session[:user_id] = nil

ve anasayfaya yönlen,

        redirect_to root_url

Url olarak http://192.168.1.2:3000/ girelim. Evet üstte,

    Hoşgeldin seyyah | Çıkış

mesajı görülüyor. çıkış yapınca,

    Giriş yapmamışsınız | Giriş yap

görülüyor sırayla logout ve login'e yönlendirme söz konusudur.

Authentication tamamdır, commitleyelim,

    $ git add .
    $ git commit -a -m "login-logout"

ve bunu depoya push edelim,

    $ git push origin auth

# Heroku

Önce heroku app oluşturalım,

    $ git checkout auth
    $ heroku create bsaral-vys-auth --stack cedar --remote heroku-bsaral-vys

app ismi `bsaral-vys-auth`, buna http://bsaral-vys-auth.herokuapp.com adresinden
ulaşabileceğimiz anlamına geliyor. Stack kısmında aksi belirtilmediği sürece
`cedar`'ı kullanın bu heroku'nun en son çıkardığı runtime stack yapısı.

https://devcenter.heroku.com/articles/cedar
https://devcenter.heroku.com/articles/stack

depoyu heroku'ya itelim,

    $ git push heroku-bsaral-vys auth:master

migrasyon ve seed,

    $ heroku run rake db:migrate --app bsaral-vys-auth
    $ heroku run rake db:seed    --app bsaral-vys-auth

Test zamanıdır, http://bsaral-vys-auth.herokuapp.com, hata mesajı alıyorum,

    We're sorry, but something went wrong.

sebebi ne acaba,

    $ heroku logs -t
    app[web.1]: [...]
    app[web.1]: ActionView::Template::Error (css/home.css isn't precompiled):
    app[web.1]: [...]

cevabı geldi bile,
