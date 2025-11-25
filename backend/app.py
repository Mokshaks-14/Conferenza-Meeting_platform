from flask import Flask, request, jsonify
from flask_cors import CORS
from deep_translator import GoogleTranslator

app = Flask(__name__)
CORS(app)

@app.route('/translate', methods=['POST'])
def translate_text():
    try:
        # 1. Get Data
        data = request.json
        if not data:
            return jsonify({"error": "No data received"}), 400

        text = data.get('text', '')
        
        # --- SAFETY FIX START ---
        # Clean the language codes (Convert 'en_US' -> 'en', 'hi_IN' -> 'hi')
        raw_source = data.get('source_lang', 'auto')
        raw_target = data.get('target_lang', 'en')

        # Split by '_' or '-' and take the first part
        source_lang = raw_source.split('_')[0].split('-')[0] if raw_source != 'auto' else 'auto'
        target_lang = raw_target.split('_')[0].split('-')[0]
        # --- SAFETY FIX END ---

        # 2. Validation
        if not text or not text.strip():
            return jsonify({"original": "", "translated": ""})

        print(f"🎤 Input: '{text}' | From: {source_lang} -> To: {target_lang}")

        # 3. Optimization: If source and target are the same, skip translation
        if source_lang == target_lang:
             print("🔸 Source equals Target. Returning original.")
             return jsonify({"original": text, "translated": text})

        # 4. Perform Translation
        translator = GoogleTranslator(source=source_lang, target=target_lang)
        translated_text = translator.translate(text)

        print(f"✅ Translated: '{translated_text}'")

        return jsonify({
            "original": text,
            "translated": translated_text
        })

    except Exception as e:
        print(f"❌ Error: {e}")
        return jsonify({
            "original": text, 
            "translated": f"Error: {str(e)}"
        }), 500

if __name__ == '__main__':
    print("🚀 Server running on http://0.0.0.0:5000")
    app.run(host='0.0.0.0', port=5000, debug=True)