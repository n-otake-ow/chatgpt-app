import os
import streamlit as st
import openai


# NOTE: set True for local development
DEBUG_MODE = os.environ.get("DEBUG_MODE", False) == "True"
openai.api_key = os.environ["OPENAI_API_KEY"]


# derived from https://docs.streamlit.io/knowledge-base/deploy/authentication-without-sso
def check_password() -> bool:
    """Returns `True` if the user had the correct password."""

    def password_entered():
        """Checks whether a password entered by the user is correct."""
        if st.session_state["password"] == st.secrets["password"]:
            st.session_state["password_correct"] = True
            del st.session_state["password"]  # don't store password
        else:
            st.session_state["password_correct"] = False

    if "password_correct" not in st.session_state:
        # First run, show input for password.
        st.text_input(
            "Password", type="password", on_change=password_entered, key="password"
        )
        return False
    elif not st.session_state["password_correct"]:
        # Password not correct, show input + error.
        st.text_input(
            "Password", type="password", on_change=password_entered, key="password"
        )
        st.error("😕 Password incorrect")
        return False
    else:
        # Password correct.
        return True


def get_answer(language: str, word: str) -> str:
    """Returns the answer to the question."""
    questions = [
        "「意味」",
        "「発音記号 (国際音声記号)」",
        "「語源」",
        "「例文」",
        "「よく出現する文脈」",
        "「豆知識」",
    ]
    question_text = ",".join(questions)

    # see https://platform.openai.com/docs/guides/chat/introduction
    res = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[
            {
                "role": "system",
                "content": """
                あなたは物知りな言語学者です。丁寧語で言葉の意味を教えてください。
                """
            },
            {
                "role": "user",
                "content": f"""
                ・{language} の {word} という言葉の {question_text} を、各項目最長 100 文字程度で教えて下さい。
                ・各項目の間は「\n\n」で改行してください。
                ・各項目の先頭には、「【項目名】\n」と記載してください。たとえば、「意味」という項目を記載する場合は、「【意味】\n」と記載してください。
                """
            },
        ],
    )
    if DEBUG_MODE:
        st.json(res)
    return res["choices"][0]["message"]["content"]


def main() -> None:
    st.title("Chat 辞書 GPT :book:")
    st.write("Chat 辞書 GPT は、単語や熟語の意味を教えてくれる辞書アプリです。")
    available_languages = (
        "フランス語",
        "ドイツ語",
        "イタリア語",
        "スペイン語",
        "英語",
        "日本語",
    )

    language = st.radio("", available_languages)
    st.write("の")
    word = st.text_input('', placeholder='Soutirage', max_chars=100)
    st.write('という言葉の意味は何ですか？')

    if st.button("質問する"):
        answer = get_answer(language, word)
        st.write(answer)
        st.write("---")
        st.write("コピペ用")
        st.code(answer)


if __name__ == "__main__":
    if DEBUG_MODE or check_password():
        main()
