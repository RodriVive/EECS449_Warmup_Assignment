walker interact {
    can return_message with `root entry {
        report {
            "response": "Hello, world!"
        };
    }
}

walker interact_with_body {
    has name: str;

    can return_message with `root entry {
        report {
            "response": "Hello, " + self.name + "!"
        };
    }
}

walker get_update {
    has type: str;

    can return_message with `root entry {
        if self.type == "weather"{
            report {
                "response": "It is sunny!"
            };
        }
        elif self.type == "date"{
            report {
                "response": "It is Sunday!"
            };
        }
    }
}

walker tell_me_something {
    has type: str;

    can return_message with `root entry {
        if self.type == "fact"{
            report {
                "response": "The first computer was invented by Charles Babbage (1822) but was not built until 1991!"
            };
        }
        elif self.type == "joke"{
            report {
                "response": "I would tell you a UDP joke, but you might not get it."
            };
        }
    }
}