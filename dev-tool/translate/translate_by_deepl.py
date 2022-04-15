import deepl
import os
from os.path import join, dirname
from dotenv import load_dotenv

load_dotenv(verbose=True)

dotenv_path = join(dirname(__file__), '.env')
load_dotenv(dotenv_path)

DEEPL_AUTH_KEY = os.environ.get("DEEPL_AUTH_KEY")

# Create a Translator object providing your DeepL API authentication key.
# Be careful not to expose your key, for example when sharing source code.
translator = deepl.Translator(DEEPL_AUTH_KEY)
# This example is for demonstration purposes only. In production code, the
# authentication key should not be hard-coded, but instead fetched from a
# configuration file or environment variable.

# Translate text into a target language, in this case, French
result = translator.translate_text("Hello, world!", target_lang="FR")
print(result)  # "Bonjour, le monde !"
# Note: printing or converting the result to a string uses the output text

# Translate multiple texts into British English
result = translator.translate_text(["Fate/StayNight", "¿Cómo estás?"], target_lang="EN-GB")
print(result[0].text)  # "How are you?"
print(result[0].detected_source_lang)  # "JA"
print(result[1].text)  # "How are you?"
print(result[1].detected_source_lang)  # "ES"

# Glossaries allow you to customize your translations
glossary_en_to_de = translator.create_glossary(
    "My glossary",
    source_lang="EN",
    target_lang="DE",
    entries={"artist": "Maler", "prize": "Gewinn"},
)

with_glossary = translator.translate_text_with_glossary(
    "The artist was awarded a prize.", glossary_en_to_de
)
print(with_glossary)  # "Der Maler wurde mit einem Gewinn ausgezeichnet."

without_glossary = translator.translate_text(
    "The artist was awarded a prize.", target_lang="DE"
)
print(without_glossary)  # "Der Künstler wurde mit einem Preis ausgezeichnet."


# Check account usage
usage = translator.get_usage()
if usage.character.limit_exceeded:
    print("Character limit exceeded.")
else:
    print(f"Character usage: {usage.character.count} of {usage.character.limit}")

# Source and target languages
print("Source languages:")
for language in translator.get_source_languages():
    print(f"{language.code} ({language.name})")  # Example: "DE (German)"

print("Target languages:")
for language in translator.get_target_languages():
    if language.supports_formality:
        print(f"{language.code} ({language.name}) supports formality")
    else:
        print(f"{language.code} ({language.name})")
