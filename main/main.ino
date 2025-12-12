#include "pitches.h"

#define PLAY_BTN_PIN 3
#define BZR_PIN 7

uint64_t romu_duo_state1 = 0x1234567890abcdef;
uint64_t romu_duo_state2 = 0xfedcba0987654321;

uint64_t romu_duo() {
    int xp = romu_duo_state1;
    romu_duo_state1 = 15241094284759029579u * romu_duo_state2;
    romu_duo_state2 = romu_duo_state2 - xp;
    romu_duo_state2 = (romu_duo_state2 << 32) | (romu_duo_state2 >> 32);
    return xp;
}

uint64_t romu_duo_range(uint64_t min, uint64_t max) {
    if (min > max) {
        uint64_t temp = min;
        min = max;
        max = temp;
    }

    uint64_t range = max - min + 1;

    if ((range & (range - 1)) == 0) {
        return min + (romu_duo() & (range - 1));
    }

    uint64_t limit = UINT64_MAX - (UINT64_MAX % range) - 1;
    uint64_t random_value;

    do {
        random_value = romu_duo();
    } while (random_value > limit);

    return min + (random_value % range);
}

float romu_duo_float() {
    uint32_t bits = (uint32_t)(romu_duo() >> 40);
    bits = 0x3F800000 | (bits & 0x007FFFFF);
    float result;
    memcpy(&result, &bits, sizeof(float));
    return result - 1.0f;
}

float romu_duo_float_range(float min, float max) {
    float t;
    uint32_t bits = (uint32_t)(romu_duo() >> 40);
    bits = 0x3F800000 | (bits & 0x007FFFFF);
    memcpy(&t, &bits, sizeof(float));
    t = t - 1.0f;
    return min + t * (max - min);
}

int melody[] = {NOTE_C4, NOTE_G3, NOTE_G3, NOTE_A3, NOTE_G3, 0, NOTE_B3, NOTE_C4};

int noteDurations[] = {4, 7, 7, 4, 4, 4, 4, 4};

void setup() {
    pinMode(PLAY_BTN_PIN, INPUT);
    pinMode(BZR_PIN, OUTPUT);
}

void loop() {
    int button = digitalRead(PLAY_BTN_PIN);

    if (button == HIGH) {
        int thisNote = romu_duo_range(0, 7);
        int noteDuration = 1000 / noteDurations[thisNote];
        tone(BZR_PIN, melody[thisNote], noteDuration);
        int pauseBetweenNotes = noteDuration * romu_duo_float_range(1.1, 1.9);
        delay(pauseBetweenNotes);
    } else {
        noTone(BZR_PIN);
    }
}
