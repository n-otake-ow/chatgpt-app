import os
from functools import wraps
import streamlit as st
import openai
from google.cloud import bigquery


# NOTE: set True for local development
GCLOUD_PROJECT = os.environ["GCLOUD_PROJECT"]
DEBUG_MODE = os.environ.get("DEBUG_MODE", "False") == "True"
FEATURE_FLAG_GCLOUD = os.environ.get("FEATURE_FLAG_GCLOUD", "True") == "True"
openai.api_key = os.environ["OPENAI_API_KEY"]


def feature_flag_gcloud(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        if FEATURE_FLAG_GCLOUD:
            return func(*args, **kwargs)

    return wrapper


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
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[
            {
                "role": "system",
                "content": """
                あなたは物知りな言語学者です。言葉の意味を丁寧語で答えてください。
                """,
            },
            {
                "role": "user",
                "content": f"""
                ・{language} の {word} という言葉の {question_text} を、各項目最長 100 文字程度で教えて下さい。
                ・各項目の間は「\n\n」で改行してください。
                ・各項目の先頭には、「【項目名】\n」と記載してください。たとえば、「意味」という項目を記載する場合は、「【意味】\n」と記載してください。
                """,
            },
        ],
    )
    log = response.copy()
    log["language"] = language
    log["word"] = word

    insert_query_log(log)

    if DEBUG_MODE:
        st.json(response)
    return response["choices"][0]["message"]["content"]


# see https://cloud.google.com/text-to-speech/docs/libraries
@feature_flag_gcloud
def speak(input_text: str) -> None:
    from google.cloud import texttospeech

    client = texttospeech.TextToSpeechClient()
    synthesis_input = texttospeech.SynthesisInput(text=input_text)

    # NOTE: you can find name from client.list_voices()
    voice = texttospeech.VoiceSelectionParams(
        language_code="ja-JP",
        name="ja-JP-Neural2-B",
    )

    audio_config = texttospeech.AudioConfig(
        audio_encoding=texttospeech.AudioEncoding.MP3
    )

    response: texttospeech.SynthesizeSpeechResponse = client.synthesize_speech(
        input=synthesis_input, voice=voice, audio_config=audio_config
    )
    st.audio(response.audio_content, format="audio/mpeg")


# derived from https://cloud.google.com/bigquery/docs/samples/bigquery-table-insert-rows
@feature_flag_gcloud
def insert_query_log(log: dict) -> None:
    client = bigquery.Client()
    table_id = f"{GCLOUD_PROJECT}.chatgpt_app.query_log"
    errors = client.insert_rows_json(table_id, [log])

    if errors == []:
        if DEBUG_MODE:
            st.write("New rows have been added.")
    else:
        st.write("Encountered errors while inserting rows: {}".format(errors))


def main() -> None:
    st.title("Chat 辞書 GPT :book:")
    st.write("Chat 辞書 GPT は、単語や熟語の意味を教えてくれる辞書アプリです。")
    available_languages = (
        "フランス語",
        "ドイツ語",
        "イタリア語",
        "スペイン語",
        "ラテン語",
        "英語",
        "日本語",
    )

    language = st.radio("", available_languages)
    st.write("の")
    word = st.text_input("", placeholder="Soutirage", max_chars=100)
    st.write("という言葉の意味は何ですか？")

    if st.button("質問する"):
        answer = get_answer(language, word)
        st.write(answer)
        speak(answer)
        st.write("---")
        st.write("コピペ用")
        st.code(answer)


if __name__ == "__main__":
    if DEBUG_MODE or check_password():
        main()
