require "rails_helper"
RSpec::Matchers.define_negated_matcher :not_change, :change

RSpec.describe "Items", type: :request do
    let(:user) { create(:user) }
    let(:board) { create(:board, user: user) }
    let(:list) { create(:list, board: board) }
    let(:item) { create(:item, list: list)}

    before do
        sign_in user
    end

    describe "GET new" do
        it "Cria uma nova Tarefa" do
            get new_list_item_path(list)
            expect(response).to have_http_status(:success)
        end
    end

    describe "POST create" do
        context "Criar uma tarefa com os parametros validos" do
            it "Cria uma nova tarefa e redireciona" do
                expect do 
                    post list_items_path(list), params: {
                        item: {
                            title: "Nova Tarefa",
                            description: "Descrição da Tarefa"
                        }
                    }
                end.to change { Item.count }.by(1)
                expect(response).to have_http_status(:redirect)
            end
        end
            
        context "Criar uma tarefa com os parametros validos" do
            it "Não cria uma tarefa e renderiza a pagina de criação de tarefa" do
                expect do
                    post list_items_path(list), params: {
                        item: {
                            title: "",
                            description: ""
                        }
                    }
                end.not_to change { Item.count }
                expect(response).to have_http_status(:success)
            end
        end
    end

    describe "GET edit" do
        it "Recupera os dados da tarefa e exibe para o usuario" do
            get edit_list_item_path(list, item)
            expect(response).to have_http_status(:success)
        end
    end

    describe "PUT update" do
        context "Alterar uma Tarefa de uma Lista com os parametros válidos" do
            it "Altera a Tarefa e redireciona para a Lista de Tarefas" do
                expect do 
                    put list_item_path(list, item), params: {
                        item: {
                            title: "Alterando o Titulo da Tarefa",
                            description: "Alterando a Descricao da Tarefa"
                        }
                    }
                end.to change { item.reload.title }.to("Alterando o Titulo da Tarefa")
                .and change {  item.reload.description }.to("Alterando a Descricao da Tarefa")
                expect(response).to have_http_status(:redirect)
            end
        end
    
        context "Alterar uma Tarefa de uma Lista com os parametros inválidos" do
            it "Não altera a Tarefa e redireciona para a página de alteração da tarefa" do
                expect do 
                    put list_item_path(list, item), params: {
                        item: {
                            title: "",
                            description: ""
                        }
                    }
                end.to not_change { item.reload.title  }
                .and not_change { item.reload.description }
                expect(response).to have_http_status(:success)
            end
        end
    end

    describe "DELETE destroy" do
        it "Exclui uma Tarefa" do
            list
            item
            expect do 
                delete list_item_path(list, item), headers: { "ACCEPT": "application/json" }
            end.to change { Item.count }.by(-1)
            expect(response).to have_http_status(:success)
        end
    end

end