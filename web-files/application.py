from datetime import datetime
# from flask_security import UserMixin, RoleMixin
from flask import Flask, render_template, url_for, request, redirect, make_response
from flask_sqlalchemy import SQLAlchemy

application = Flask(__name__)
application.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///blog.db'
application.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)


class Article(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(100), nullable=False)
    subtitle = db.Column(db.String(300), nullable=False)
    text = db.Column(db.Text, nullable=False)
    date = db.Column(db.DateTime, default=datetime.utcnow)

    def __repr__(self):
        return '<Article %r>' % self.id


@application.route('/')
@application.route('/home')
def index():
    return render_template("index.html")


@application.route('/about')
def about():
    return render_template("about.html")


@application.route('/posts')
def posts():
    articles = Article.query.order_by(Article.date.desc()).all()
    return render_template("posts.html", articles=articles)


@application.route('/posts/<int:id>')
def post_detail(id):
    article = Article.query.get(id)
    return render_template("post_detail.html", article=article)


@application.route('/posts/<int:id>/del')
def post_delete(id):
    article = Article.query.get_or_404(id)

    try:
        db.session.delete(article)
        db.session.commit()
        return redirect('/posts')
    except:
        return "При удалении статьи произошла ошибка."


@application.route('/posts/<int:id>/edit', methods=['POST', 'GET'])
def post_edit(id):
    article = Article.query.get(id)
    if request.method == 'POST':
        article.title = request.form['title']
        article.subtitle = request.form['subtitle']
        article.text = request.form['text']

        try:
            db.session.commit()
            return redirect('/posts')
        except:
            return "При редактировании статьи произошла ошибка."
    else:
        return render_template("post_edit.html", article=article)


@application.route('/create-article', methods=['POST', 'GET'])
def create_article():
    if request.method == 'POST':
        title = request.form['title']
        subtitle = request.form['subtitle']
        text = request.form['text']

        article = Article(title=title, subtitle=subtitle, text=text)

        try:
            db.session.add(article)
            db.session.commit()
            return redirect('/posts')
        except:
            return "При добавлении статьи произошла ошибка."
    else:
        return render_template("create-article.html")


@application.route("/login")
def login():
    return render_template("login.html")


@application.route("/signup")
def signup():
    return render_template("signup.html")

    # log = ""
    # if request.cookies.get('logged'):
    #    log = request.cookies.get('logged')

    # res = make_response(f"<h1>Форма авторизации</h1><p>logged: {log}")
    # res.set_cookie("logged", "yes")
    # return res


@application.route("/logout")
def logout():
    res = make_response("<p>Вы вышли из аккаунта.</p>")
    res.set_cookie("logged", "", 0)
    return res


if __name__ == '__main__':
    application.run(debug=True)

# Flask security

"""
class User(db.Model, UserMixin):
    id = db.Column()
"""
