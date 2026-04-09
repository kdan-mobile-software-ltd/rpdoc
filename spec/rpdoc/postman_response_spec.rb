# frozen_string_literal: true

require "tempfile"
require "rack/test"
require "action_dispatch/http/upload"
require "rpdoc"

describe Rpdoc::PostmanResponse do
  subject(:formdata) { postman_response.data.dig(:originalRequest, :body, :formdata) }

  let(:example) do
    double(
      :example,
      metadata: {
        rpdoc_action_name: "create ticket",
        rpdoc_example_name: "creates ticket",
        rpdoc_example_key: "creates_ticket",
        rpdoc_action_key: "create",
        rpdoc_example_folders: ["api", "tickets"],
        location: "spec/requests/api/tickets_spec.rb:10"
      }
    )
  end
  let(:request_headers) { { "Content-Type" => "multipart/form-data; boundary=test-boundary" } }
  let(:request) do
    double(
      :request,
      headers: request_headers,
      query_string: "",
      original_fullpath: "/api/tickets",
      method: "POST",
      form_data?: true,
      request_parameters: request_parameters
    )
  end
  let(:response_headers) { { "Content-Type" => "application/json" } }
  let(:response) do
    double(
      :response,
      header: response_headers,
      headers: response_headers,
      status: "200",
      code: "200",
      body: "{}"
    )
  end
  let(:postman_response) { described_class.new(example, request, response) }

  def build_uploaded_file(filename)
    tempfile = Tempfile.new(filename)
    tempfile.write("sample content for #{filename}")
    tempfile.rewind

    ActionDispatch::Http::UploadedFile.new(
      tempfile: tempfile,
      filename: filename,
      type: "text/plain"
    )
  end

  def build_rack_uploaded_file(filename)
    tempfile = Tempfile.new(filename)
    tempfile.write("sample content for #{filename}")
    tempfile.rewind

    Rack::Test::UploadedFile.new(tempfile.path, "text/plain", original_filename: filename)
  end

  context "when request contains a single uploaded file" do
    let(:request_parameters) { { file: build_uploaded_file("single.txt") } }

    it "serializes the file field as Postman form-data" do
      expect(formdata).to eq(
        [
          {
            key: "file",
            src: "single.txt",
            type: "file"
          }
        ]
      )
    end
  end

  context "when request contains an uploaded file array" do
    let(:request_parameters) do
      {
        attachments: [
          build_uploaded_file("first.txt"),
          build_uploaded_file("second.txt")
        ]
      }
    end

    it "serializes each file using the [] suffix" do
      expect(formdata).to eq(
        [
          {
            key: "attachments[]",
            src: "first.txt",
            type: "file"
          },
          {
            key: "attachments[]",
            src: "second.txt",
            type: "file"
          }
        ]
      )
    end
  end

  context "when request contains a nested uploaded file array" do
    let(:request_parameters) do
      {
        payload: {
          attachments: [
            build_uploaded_file("nested-1.txt"),
            build_uploaded_file("nested-2.txt")
          ]
        }
      }
    end

    it "preserves nested keys for file array entries" do
      expect(formdata).to eq(
        [
          {
            key: "payload[attachments][]",
            src: "nested-1.txt",
            type: "file"
          },
          {
            key: "payload[attachments][]",
            src: "nested-2.txt",
            type: "file"
          }
        ]
      )
    end
  end

  context "when request contains Rack::Test uploaded files" do
    let(:request_parameters) do
      {
        attachments: [
          build_rack_uploaded_file("rack-1.txt"),
          build_rack_uploaded_file("rack-2.txt")
        ]
      }
    end

    it "serializes Rack::Test::UploadedFile entries as file form-data" do
      expect(formdata).to eq(
        [
          {
            key: "attachments[]",
            src: "rack-1.txt",
            type: "file"
          },
          {
            key: "attachments[]",
            src: "rack-2.txt",
            type: "file"
          }
        ]
      )
    end
  end

  context "when request mixes text and file fields" do
    let(:request_parameters) do
      {
        subject: "Login Issue",
        attachments: [build_uploaded_file("ticket.txt")]
      }
    end

    it "keeps text fields as text and file fields as file entries" do
      expect(formdata).to eq(
        [
          {
            key: "subject",
            value: "Login Issue",
            type: "text"
          },
          {
            key: "attachments[]",
            src: "ticket.txt",
            type: "file"
          }
        ]
      )
    end
  end

  context "when request contains nested text structures" do
    let(:request_parameters) do
      {
        payload: {
          subject: "Login Issue",
          tags: ["bug", "urgent"]
        }
      }
    end

    it "preserves the existing text output format for nested hashes and arrays" do
      expect(formdata).to eq(
        [
          {
            key: "payload[subject]",
            value: "Login Issue",
            type: "text"
          },
          {
            key: "payload[tags][]",
            value: "bug",
            type: "text"
          },
          {
            key: "payload[tags][]",
            value: "urgent",
            type: "text"
          }
        ]
      )
    end
  end
end
