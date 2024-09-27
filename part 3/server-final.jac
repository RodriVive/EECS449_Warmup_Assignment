import:py from mtllm.llms {Ollama}
import:jac from rag {RagEngine}

import:py from mtllm.llms {OpenAI}
glob llm = OpenAI(model_name='gpt-3.5-turbo');

enum ChatType {
    RAG : 'Need to use Retrievable information in specific documents to respond' = "RAG",
    QA : 'Given context is enough for an answer' = "user_qa",
    H: 'User is having a personal or emotional problem' = "user_h"
}


node Router {
    can 'route the query to the appropriate task type'
    classify(message:'query from the user to be routed.':str) -> ChatType by llm(method="Reason", temperature=0.0);
}

node Chat {
    has chat_type: ChatType;
}

walker infer {
    has message:str;
    has chat_history: list[dict];

    can init_router with `root entry {
        visit [-->](`?Router) else {
            router_node = here ++> Router();
            router_node ++> HChat();
            router_node ++> RagChat();
            router_node ++> QAChat();

            visit router_node;
        }
    }
    can route with Router entry {
        classification = here.classify(message = self.message);
        print(classification, self.message);
        chats = [-->](`?Chat);
        print(chats);
        visit [-->](`?Chat)(?chat_type==classification);
    }
}

node QAChat :Chat: {
    has chat_type: ChatType = ChatType.QA;
    can respond with infer entry {
        print('QA');
        can 'Respond to message using chat_history as context and agent_role as the goal of the agent'
        respond_with_llm(   message:'current message':str,
            chat_history: 'chat history':list[dict],
            agent_role:'role of the agent responding':str
                ) -> 'response':str by llm();
        here.response = respond_with_llm(here.message, here.chat_history, agent_role="You are a conversation agent designed to help users with their non-personal queries");
    }
}

node HChat :Chat: {
    has chat_type: ChatType = ChatType.H;

    can respond with infer entry {
        print('H');

        can 'Respond to message using chat_history as context and agent_role as the goal of the agent'
        respond_with_llm(   message:'current message':str,
            chat_history: 'chat history':list[dict],
            agent_role:'role of the agent responding':str
                ) -> 'response':str by llm();
        here.response = respond_with_llm(here.message, here.chat_history, agent_role="You are an emotional assistant tasked with helping users with their personal problems");
    }
}

node RagChat :Chat: {
    has chat_type: ChatType = ChatType.RAG;

    can respond with infer entry {
        print('RAG');

        can 'Respond to message using chat_history as context and agent_role as the goal of the agent'
        respond_with_llm(   message:'current message':str,
                    chat_history: 'chat history':list[dict],
                    agent_role:'role of the agent responding':str,
                    context:'retirved context from documents':list
                        ) -> 'response':str by llm();
        data = rag_engine.get_from_chroma(query=here.message);
        here.response = respond_with_llm(here.message, here.chat_history, "You are a conversation agent designed to help users with their queries based on the documents provided", data);
    }
}

walker interact {
    has message: str;
    has session_id: str;

    can init_session with `root entry {
         visit [-->](`?Session)(?id == self.session_id) else {
            session_node = here ++> Session(id=self.session_id, chat_history=[], status=1);
            print("Session Node Created");

            visit session_node;
        }
    }
}

node Session {
    has id: str;
    has chat_history: list[dict];
    has status: int = 1;

    can 'Respond to message using chat_history as context and agent_role as the goal of the agent'
    llm_chat(
        message:'current message':str,
        chat_history: 'chat history':list[dict],
        agent_role:'role of the agent responding':str,
        context:'retrieved context from documents':list
    ) -> 'response':str by llm();

    can chat with interact entry {
        self.chat_history.append({"role": "user", "content": here.message});
        response = infer(message=here.message, chat_history=self.chat_history) spawn root;
        print(response.response);
        self.chat_history.append({"role": "assistant", "content": response.response});
        
        report {
            "response": response.response
        };
    }
}


with entry:__main__ {
    rag_engine = RagEngine();
    rag_engine.init(file_path="docs", chroma_path="chroma");
    print("RagEngine initialized:", rag_engine);
}